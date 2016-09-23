# bufio

## Reader

`bufio.Reader`对`io.Reader`进行了包装，提供了缓冲区功能。定义如下：

```go
type Reader struct {
    buf          []byte
    rd           io.Reader // reader provided by the client
    r, w         int       // buf read and write positions
    err          error
    lastByte     int       // 最后一个读取的字节，用于UnreadByte操作
    lastRuneSize int       // 最后一个读取rune的大小，用于UnreadRune操作
}
```

### 创建

通过`NewReader(rd io.Reader)`可以创建一个新的Reader：

```go
func NewReader(rd io.Reader) *Reader {
    // const defaultBufSize = 4096
    // 默认缓冲区大小为4K
    return NewReaderSize(rd, defaultBufSize)
}
```

可以看到，`NewReader`实际上是调用了`NewReaderSize`方法，`NewReaderSize`会创建一个具有特定大小缓冲区的Reader：

```go
func NewReaderSize(rd io.Reader, size int) *Reader {
    // Is it already a Reader?
    b, ok := rd.(*Reader)
    if ok && len(b.buf) >= size {
        return b
    }
    // const minReadBufferSize = 16
    // 缓冲区最小为16byte
    if size < minReadBufferSize {
        size = minReadBufferSize
    }
    r := new(Reader)
    r.reset(make([]byte, size), rd)
    return r
}

func (b *Reader) reset(buf []byte, r io.Reader) {
    *b = Reader{
        buf:          buf,
        rd:           r,
        lastByte:     -1,
        lastRuneSize: -1,
    }
}
```

### read

和读操作相关的方法有：

- func (b *Reader) Read(p []byte) (n int, err error)
- func (b *Reader) ReadByte() (byte, error)
- func (b *Reader) ReadRune() (r rune, size int, err error)
- func (b *Reader) UnreadByte() error
- func (b *Reader) UnreadRune() error
- func (b *Reader) ReadSlice(delim byte) (line []byte, err error)
- func (b *Reader) ReadLine() (line []byte, isPrefix bool, err error)
- func (b *Reader) ReadBytes(delim byte) ([]byte, error)
- func (b *Reader) ReadString(delim byte) (string, error)

其中`Read`方法源码为：

```go
func (b *Reader) Read(p []byte) (n int, err error) {
    n = len(p)
    if n == 0 {
        return 0, b.readErr()
    }
    // 如果b.r == b.w，则当前缓冲区中无数据
    if b.r == b.w {
        if b.err != nil {
            return 0, b.readErr()
        }
        // 如果p的大小大于等于缓冲区大小，则直接将数据读入p，然后返回
        if len(p) >= len(b.buf) {
            // Large read, empty buffer.
            // Read directly into p to avoid copy.
            n, b.err = b.rd.Read(p)
            if n < 0 {
                panic(errNegativeRead)
            }
            if n > 0 {
                b.lastByte = int(p[n-1])
                b.lastRuneSize = -1
            }
            return n, b.readErr()
        }
        // 如果p的大小小于缓冲区大小，则先将数据读入缓冲区
        b.fill() // buffer is empty
        if b.r == b.w {
            return 0, b.readErr()
        }
    }

    // 将缓冲区中的数据尽可能的拷贝到p中
    n = copy(p, b.buf[b.r:b.w])
    b.r += n
    b.lastByte = int(b.buf[b.r-1])
    b.lastRuneSize = -1
    return n, nil
}
```

`ReadSlice(delim byte)`会读取数据直到遇到分隔符`delim`。如果在遇到`delim`之前出错了或者缓冲区满了，也会退出。

`ReadLine()`会读取一行数据，同样，在遇到换行符之前，如果出错了或者缓冲区满了，也会退出。因此该方法并不能保证遇到换行符的时候返回，也就是说，读到的数据可能并不够一行。例如：

```go
r := strings.NewReader("0123456789abcdefghijklmn\nopqrstuvwxyz")
br := bufio.NewReaderSize(r, 16)
line, isPrefix, err := br.ReadLine()
fmt.Println(string(line)) // 0123456789abcdef
fmt.Println(isPrefix)     // true
fmt.Println(err)          // <nil>  
```

因此，如果想要按行读取数据，使用`ReadBytes('\n')`或者`ReadString('\n')`会是更好的选择。`ReadString`实际上调用了`ReadBytes`，只不过将数据转成了字符串而已。`ReadBytes(delim byte)`会不断地读取数据，直到遇到分隔符`delim`。例如：

```go
r := strings.NewReader("0123456789abcdefghijklmn\nopqrstuvwxyz")
br := bufio.NewReaderSize(r, 16)
line, err := br.ReadBytes('\n')
fmt.Println(string(line)) // 0123456789abcdefghijklmn
fmt.Println(err)          // <nil>
```

### 其它操作

- func (b *Reader) Buffered() int
- func (b *Reader) Reset(r io.Reader)
- func (b *Reader) Discard(n int) (discarded int, err error)
- func (b *Reader) Peek(n int) ([]byte, error)
- func (b *Reader) WriteTo(w io.Writer) (n int64, err error)

`Buffered`返回当前缓冲区中的可用数据量：

```go
func (b *Reader) Buffered() int { return b.w - b.r }
```

`Reset`会重置数据源，之后的数据读取都会从新的数据源中来读：

```go
func (b *Reader) Reset(r io.Reader) {
    b.reset(b.buf, r)
}
```

`Discard(n int)`会跳过之后的`n`个字节，例如：

```go
br := bufio.NewReader(strings.NewReader("0123456789"))
p := make([]byte, 5)
br.Discard(3)
br.Read(p)
fmt.Println(string(p)) // 34567
```

`Peek(n int)`用于查看接下来的`n`个字节数据，但是并不真正读取，例如：

```go
br := bufio.NewReader(strings.NewReader("0123456789"))
p := make([]byte, 5)
br.Peek(3)
br.Read(p)
fmt.Println(string(p)) // 01234
```

`WriteTo`将数据写入到一个Writer中，因此`bufio.Reader`实现了`io.WriterTo`接口。

## Writer