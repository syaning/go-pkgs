# bytes

## 基本操作

### 比较

和比较相关的方法有：

- func Equal(a, b []byte) bool
- func EqualFold(s, t []byte) bool
- func Compare(a, b []byte) int

其中`Equal`和`Compare`是使用汇编来实现的。

例如：

```go
a := []byte("hello")
b := []byte("world")
fmt.Println(bytes.Equal(a, b))   // false
fmt.Println(bytes.Compare(a, b)) // -1
fmt.Println(bytes.Compare(b, a)) // 1
```

`EqualFold`会忽略大小写，同时会将特殊字符进行转换。例如：

```go
a := []byte("hello ϕ")
b := []byte("Hello Φ")
fmt.Println(bytes.EqualFold(a, b)) // true
```

### index

和index相关的方法有：

- func Index(s, sep []byte) int
- func IndexAny(s []byte, chars string) int
- func IndexByte(s []byte, c byte) int
- func IndexFunc(s []byte, f func(r rune) bool) int
- func IndexRune(s []byte, r rune) int
- func LastIndex(s, sep []byte) int
- func LastIndexAny(s []byte, chars string) int
- func LastIndexByte(s []byte, c byte) int
- func LastIndexFunc(s []byte, f func(r rune) bool) int

例如：

```go
s := []byte("Hello 世界")
fmt.Println(bytes.Index(s, []byte("llo"))) // 2
fmt.Println(bytes.IndexAny(s, "ole"))      // 1
fmt.Println(bytes.IndexByte(s, 'l'))       // 2
fmt.Println(bytes.IndexRune(s, '界'))       // 9
```

### 包含

和包含相关的方法有：

- func Contains(b, subslice []byte) bool
- func ContainsAny(b []byte, chars string) bool
- func ContainsRune(b []byte, r rune) bool
- func Count(s, sep []byte) int
- func HasPrefix(s, prefix []byte) bool
- func HasSuffix(s, suffix []byte) bool

例如：

```go
s := []byte("Hello 世界")
fmt.Println(bytes.Contains(s, []byte("llo"))) // true
fmt.Println(bytes.ContainsAny(s, "llo"))      // true
fmt.Println(bytes.ContainsRune(s, '世'))       // true
fmt.Println(bytes.Count(s, []byte("llo")))    // 1
fmt.Println(bytes.HasPrefix(s, []byte("llo"))) // false
fmt.Println(bytes.HasSuffix(s, []byte("世界")))  // true
```

在源码中，`Contains[Any/Rune]`是通过`Index[Any/Rune]`来实现的，例如：

```go
func ContainsAny(b []byte, chars string) bool {
    return IndexAny(b, chars) >= 0
}
```

`HasPrefix`和`HasSuffix`是通过`Equal`来实现的，例如：

```go
func HasPrefix(s, prefix []byte) bool {
    return len(s) >= len(prefix) && Equal(s[0:len(prefix)], prefix)
}
```

###转换

和转换相关的方法有：

- func Title(s []byte) []byte
- func ToLower(s []byte) []byte
- func ToLowerSpecial(_case unicode.SpecialCase, s []byte) []byte
- func ToTitle(s []byte) []byte
- func ToTitleSpecial(_case unicode.SpecialCase, s []byte) []byte
- func ToUpper(s []byte) []byte
- func ToUpperSpecial(_case unicode.SpecialCase, s []byte) []byte

例如：

```go
s := []byte("heLLo 世界")
fmt.Println(string(bytes.Title(s)))   // HeLLo 世界
fmt.Println(string(bytes.ToLower(s))) // hello 世界
fmt.Println(string(bytes.ToTitle(s))) // HELLO 世界
fmt.Println(string(bytes.ToUpper(s))) // HELLO 世界
```

### trim

和trim相关的方法有：

- func Trim(s []byte, cutset string) []byte
- func TrimFunc(s []byte, f func(r rune) bool) []byte
- func TrimLeft(s []byte, cutset string) []byte
- func TrimLeftFunc(s []byte, f func(r rune) bool) []byte
- func TrimPrefix(s, prefix []byte) []byte
- func TrimRight(s []byte, cutset string) []byte
- func TrimRightFunc(s []byte, f func(r rune) bool) []byte
- func TrimSpace(s []byte) []byte
- func TrimSuffix(s, suffix []byte) []byte

例如：

```go
s := []byte("hello olleh")
fmt.Println(string(bytes.TrimLeft(s, "hel")))            // o olleh
fmt.Println(string(bytes.TrimRight(s, "hel")))           // hello o
fmt.Println(string(bytes.Trim(s, "hel")))                // o o
fmt.Println(string(bytes.TrimPrefix(s, []byte("hel"))))  // lo olleh
fmt.Println(string(bytes.TrimSuffix(s, []byte("lleh")))) // hello o
```

其中最基本的两个方法是`TrimLeftFunc`和`TrimRightFunc`，`TrimLeft`，`TrimRight`，`TrimFunc`都是基于这两个方法。例如：

```go
func TrimFunc(s []byte, f func(r rune) bool) []byte {
    return TrimRightFunc(TrimLeftFunc(s, f), f)
}
```

`Trim`和`TrimSpace`都是基于`TrimFunc`方法。

`TrimPrefix`和`TrimSuffix`其实都是简单使用了切片操作。

### split 和 join

相关方法有：

- func Split(s, sep []byte) [][]byte
- func SplitAfter(s, sep []byte) [][]byte
- func SplitAfterN(s, sep []byte, n int) [][]byte
- func SplitN(s, sep []byte, n int) [][]byte
- func Fields(s []byte) [][]byte
- func FieldsFunc(s []byte, f func(rune) bool) [][]byte
- func Join(s [][]byte, sep []byte) []byte

例如：

```go
s := []byte("hello,world,welcome")

arr := bytes.Split(s, []byte(","))
for _, a := range arr {
    fmt.Print(string(a), " ")
}
// hello world welcome

arr = bytes.SplitAfter(s, []byte(","))
for _, a := range arr {
    fmt.Print(string(a), " ")
}
// hello, world, welcome
```

`SplitAfter`相比于`Split`，会包含分隔符。

`SplitN`和`SplitAfterN`与`Split`和`SplitAfter`相似，只不过限制了最大的切分个数，超过部分不再切分。例如：

```go
s := []byte("hello,world,welcome")

arr := bytes.SplitN(s, []byte(","), 2)
for _, a := range arr {
    fmt.Print(string(a), " ")
}
// hello world,welcome
```

`Fields`是通过连续的空字符来切分，例如：

```go
s := []byte("  hello  world   welcome ")
arr := bytes.Fields(s)
for _, a := range arr {
    fmt.Print(string(a), " ")
}
// hello world welcome
```

`FieldsFunc`则是通过一个函数来检测切分条件，实际上，`Fields`是调用了`FieldsFunc`：

```go
func Fields(s []byte) [][]byte {
    return FieldsFunc(s, unicode.IsSpace)
}
```

`Join`用于连接操作，例如：

```go
s := [][]byte{
    []byte("hello"),
    []byte("world"),
    []byte("welcome"),
}
fmt.Println(string(bytes.Join(s, []byte(", "))))
// hello, world, welcome
```

### 其它操作

- func Map(mapping func(r rune) rune, s []byte) []byte
- func Repeat(b []byte, count int) []byte
- func Replace(s, old, new []byte, n int) []byte
- func Runes(s []byte) []rune

例如：

```go
s := []byte("hello")
fmt.Println(string(bytes.Repeat(s, 3)))                             // hellohellohello
fmt.Println(string(bytes.Replace(s, []byte("l"), []byte("L"), 1)))  // heLlo
fmt.Println(string(bytes.Replace(s, []byte("l"), []byte("L"), -1))) // heLLo

s = []byte("hello 世界")
fmt.Println(s)              // [104 101 108 108 111 32 228 184 150 231 149 140]
fmt.Println(bytes.Runes(s)) // [104 101 108 108 111 32 19990 30028]

f := func(r rune) rune { return r + 1 }
fmt.Println(string(bytes.Map(f, []byte("abcdefg")))) // bcdefgh
```

## Buffer

`Buffer`定义了一个缓冲区，其定义如下：

```go
type Buffer struct {
    buf       []byte            // contents are the bytes buf[off : len(buf)]
    off       int               // read at &buf[off], write at &buf[len(buf)]
    runeBytes [utf8.UTFMax]byte // avoid allocation of slice on each call to WriteRune
    bootstrap [64]byte          // memory to hold first slice; helps small buffers avoid allocation.
    lastRead  readOp            // last read operation, so that Unread* can work correctly.
}
```

它有一个内在的`buf`用于存储缓冲数据，`off`表示缓冲区起始位置。因此实际的数据位于`off`到`len(buf)`之间。执行`Read`操作的时候，会修改`off`的值；执行`Write`操作的时候，会改变`buf`的长度。

可以通过如下方式创建新的`Buffer`：

```go
var a bytes.Buffer
b := bytes.NewBuffer([]byte("hello"))
c := bytes.NewBufferString("hello")
```

### 基本操作

`Buffer`的基本操作有：

- func (b *Buffer) Len() int
- func (b *Buffer) Cap() int
- func (b *Buffer) Bytes() []byte
- func (b *Buffer) String() string

例如：

```go
buf := bytes.NewBufferString("hello")
buf.ReadByte()
fmt.Println(buf.Len())    // 4
fmt.Println(buf.Cap())    // 8
fmt.Println(buf.Bytes())  // [101 108 108 111]
fmt.Println(buf.String()) // ello
```

### Truncate 和 Grow

`Truncate`可以截短缓冲区：

```go
func (b *Buffer) Truncate(n int) {
    b.lastRead = opInvalid
    switch {
    case n < 0 || n > b.Len():
        panic("bytes.Buffer: truncation out of range")
    case n == 0:
        // Reuse buffer space.
        b.off = 0
    }
    // 截取前n个缓冲数据，如果n为0，则相当于buf重置
    b.buf = b.buf[0 : b.off+n]
}
```

例如：

```go
buf := bytes.NewBufferString("hello")
buf.Truncate(3)
fmt.Println(buf) // hel
buf.Truncate(0)
fmt.Println(buf.Len()) // 0
```

`Reset`方法其实就是执行了`Truncate(0)`。

`Grow`可以扩展缓冲区从而确保可以容纳更多缓冲数据：

```go
func (b *Buffer) Grow(n int) {
    if n < 0 {
        panic("bytes.Buffer.Grow: negative count")
    }
    m := b.grow(n)
    // grow操作会在缓冲数据区之后增加一片空白区域
    // m表示的是数据区的末尾位置
    // 因此这里需要通过切片操作保证Len操作的正确性
    b.buf = b.buf[0:m]
}

func (b *Buffer) grow(n int) int {
    m := b.Len()
    // 如果缓冲区为空，则重置
    if m == 0 && b.off != 0 {
        b.Truncate(0)
    }
    // 超出缓冲区容量
    if len(b.buf)+n > cap(b.buf) {
        var buf []byte
        // 初始化缓冲区
        if b.buf == nil && n <= len(b.bootstrap) {
            buf = b.bootstrap[0:]
        } else if m+n <= cap(b.buf)/2 {
            // We can slide things down instead of allocating a new
            // slice. We only need m+n <= cap(b.buf) to slide, but
            // we instead let capacity get twice as large so we
            // don't spend all our time copying.
            // m为当前缓冲区的数据量，n为扩展大小，或者说即将写入的数据量
            // 因此m+n可以理解为新的缓冲数据量
            // 如果缓冲数据量不超过一半容量，则不需要新分配内存
            copy(b.buf[:], b.buf[b.off:])
            buf = b.buf[:m]
        } else {
            // 如果缓冲数据量超过一半容量，则需要新分配内存
            buf = makeSlice(2*cap(b.buf) + n)
            copy(buf, b.buf[b.off:])
        }
        b.buf = buf
        b.off = 0
    }
    b.buf = b.buf[0 : b.off+m+n]
    return b.off + m
}
```

### read

`Read`操作从缓冲区中读取数据：

```go
func (b *Buffer) Read(p []byte) (n int, err error) {
    b.lastRead = opInvalid
    // 缓冲区为空，重置
    if b.off >= len(b.buf) {
        b.Truncate(0)
        if len(p) == 0 {
            return
        }
        return 0, io.EOF
    }
    // 将数据从缓冲区中拷贝出来，并更新off的值
    n = copy(p, b.buf[b.off:])
    b.off += n
    if n > 0 {
        b.lastRead = opRead
    }
    return
}
```

例如：

```go
buf := bytes.NewBufferString("hello world")
p := make([]byte, 3)
buf.Read(p)
fmt.Println(string(p)) // hel
```

`Next`方法与`Read`基本类似，只不过参数不是一个slice而是一个数值表示要读取的数据量，另外一个区别是：`Read`操作是从缓冲区拷贝数据到新的slice，而`Next`是对当前缓冲区直接进行slice操作并返回结果。

```go
func (b *Buffer) Next(n int) []byte {
    b.lastRead = opInvalid
    m := b.Len()
    if n > m {
        n = m
    }
    // 对当前缓冲区直接进行slice操作
    data := b.buf[b.off : b.off+n]
    b.off += n
    if n > 0 {
        b.lastRead = opRead
    }
    return data
}
```

其它与read相关的方法有：

- func (b *Buffer) ReadByte() (byte, error)
- func (b *Buffer) ReadBytes(delim byte) (line []byte, err error)
- func (b *Buffer) ReadRune() (r rune, size int, err error)
- func (b *Buffer) ReadString(delim byte) (line string, err error)

例如：

```go
buf := bytes.NewBufferString("hello,世界!")

c, _ := buf.ReadByte()
fmt.Println(string(c)) // h

s, _ := buf.ReadBytes(',')
fmt.Println(string(s)) // ello,

r, _, _ := buf.ReadRune()
fmt.Println(string(r)) // 世

l, _ := buf.ReadString('!')
fmt.Println(l) // 界!
```

### write

`Write`用于向缓冲区中写入数据：

```go
func (b *Buffer) Write(p []byte) (n int, err error) {
    b.lastRead = opInvalid
    // 首先通过grow操作确保缓冲区可以容纳更多的数据
    m := b.grow(len(p))
    // 将数据拷贝到缓冲区中
    return copy(b.buf[m:], p), nil
}
```

其相关的方法有：

- func (b *Buffer) Write(p []byte) (n int, err error)
- func (b *Buffer) WriteByte(c byte) error
- func (b *Buffer) WriteRune(r rune) (n int, err error)
- func (b *Buffer) WriteString(s string) (n int, err error)

例如：

```go
var buf bytes.Buffer

buf.Write([]byte("hello"))
fmt.Println(buf.String()) // hello

buf.WriteByte(',')
fmt.Println(buf.String()) // hello,

buf.WriteRune('世')
fmt.Println(buf.String()) // hello,世

buf.WriteString("界!")
fmt.Println(buf.String()) // hello,世界!
```

### unread

unread操作会将已经读取的数据重新归入到缓冲区，本质上就是减小`off`的值。相关的方法有：

- func (b *Buffer) UnreadByte() error
- func (b *Buffer) UnreadRune() error

```go
func (b *Buffer) UnreadByte() error {
    // 只有当上一次的操作是读操作的时候才可以执行unread操作
    if b.lastRead != opReadRune && b.lastRead != opRead {
        return errors.New("bytes.Buffer: UnreadByte: previous operation was not a read")
    }
    b.lastRead = opInvalid
    if b.off > 0 {
        b.off--
    }
    return nil
}
```

例如：

```go
buf := bytes.NewBufferString("hello")

buf.Read(make([]byte, 3))
fmt.Println(buf) // lo

err := buf.UnreadByte()
if err != nil {
    fmt.Println(err)
} else {
    fmt.Println(buf) // llo
}

buf.WriteByte('a')
err = buf.UnreadByte()
if err != nil {
    fmt.Println(err) // bytes.Buffer: UnreadByte: previous operation was not a read
} else {
    fmt.Println(buf)
}
```

### ReadFrom 和 WriteTo

- func (b *Buffer) ReadFrom(r io.Reader) (n int64, err error)
- func (b *Buffer) WriteTo(w io.Writer) (n int64, err error)

`ReadFrom`从一个reader中读取数据到缓冲区，`WriteTo`将缓冲区中的数据写入到一个writer中。例如：

```go
r := bytes.NewReader([]byte("hello world"))
buf := new(bytes.Buffer)

buf.ReadFrom(r)
buf.WriteTo(os.Stdout)
```

## Reader

`bytes.Reader`可以将一个`[]byte`类型作为reader来使用，通过`NewReader`方法可以和粗昂见一个reader，例如：

```go
r := bytes.NewReader([]byte("hello world"))
b := make([]byte, 5)
r.Read(b)
fmt.Println(string(b)) // hello
```

其定义如下：

```go
type Reader struct {
    s        []byte
    i        int64 // current reading index
    prevRune int   // index of previous rune; or < 0
}
```

其中`s`存放着数据，`i`表示当前读取到的下标，`prevRune`记录着之前读取的一个rune的下标，用于`UnreadRune`操作。

### 基本操作

- func (r *Reader) Len() int
- func (r *Reader) Size() int64
- func (r *Reader) Reset(b []byte)

`Len`返回的是未读取的数据长度，`Size`返回的是总的数据长度，`Reset`重置了数据区。例如：

```go
r := bytes.NewReader([]byte("hello world"))
r.ReadByte()
fmt.Println(r.Len())  // 10
fmt.Println(r.Size()) // 11
r.Reset([]byte("welcome"))
fmt.Println(r.Len()) // 7
```

这几个方法的源码比较简单，不做赘述。

### read

和read相关的方法有：

- func (r *Reader) Read(b []byte) (n int, err error)
- func (r *Reader) ReadByte() (byte, error)
- func (r *Reader) ReadRune() (ch rune, size int, err error)
- func (r *Reader) ReadAt(b []byte, off int64) (n int, err error)

它们本质上都是讲数据从`reader.s`拷贝出来，然后更新`reader.i`的值。其中`ReadAt`是从特定位置读取数据，例如：

```go
r := bytes.NewReader([]byte("hello world"))
b := make([]byte, 5)
r.ReadAt(b, 6)
fmt.Println(string(b)) // world
```

### unread

有两个方法：

- func (r *Reader) UnreadByte() error
- func (r *Reader) UnreadRune() error

其中`UnreadByte`只有在数据已经读取了之后才有效，`UnreadRune`只有在`ReadRune`之后才有效。源码比较简单，不做赘述。

### Seek

`Seek`方法本质上是改变了`reader.i`的值。例如：

```go
r := bytes.NewReader([]byte("hello world"))

r.Seek(4, io.SeekStart)
b, _ := r.ReadByte()
fmt.Println(string(b)) // o

r.Seek(3, io.SeekCurrent)
b, _ = r.ReadByte()
fmt.Println(string(b)) // r

r.Seek(-4, io.SeekEnd)
b, _ = r.ReadByte()
fmt.Println(string(b)) // o
}
```

### WriteTo

`WriteTo`可以将数据写入到一个writer中，例如：

```go
r := bytes.NewReader([]byte("hello world"))
r.WriteTo(os.Stdout)
```
