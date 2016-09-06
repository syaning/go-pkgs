# io

## Reader

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

`Reader`只有一个`Read`方法，该方法从数据源中读取长度为`len(p)`的字节，存储到`p`中，返回读取的字节数和遇到的错误。

## Writer

```go
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

`Writer`只有一个`Write`方法，该方法将`p`中的数据写入到数据流中，返回写入的字节数和遇到的错误。

## Closer 和 Seeker

```go
type Closer interface {
    Close() error
}
```

`Closer`接口封装了`Close`方法。

```go
type Seeker interface {
    Seek(offset int64, whence int) (ret int64, err error)
}
```

`Seeker`只有一个`Seek`方法，用于设置下一次读或写的偏移量。其中`whence`的取值：

- 0：相对于头部
- 1：相对于当前偏移量
- 2：相对于尾部

## 组合接口

基于`Reader`、`Writer`、`Closer`、`Seeker`的组合，产生如下接口：

- ReadWriter
- ReadCloser
- WriteCloser
- ReadWriteCloser
- ReadSeeker
- WriteSeeker
- ReadWriteSeeker

## 其它接口

`ReaderFrom`从一个`Reader`读取数据。

```go
type ReaderFrom interface {
    ReadFrom(r Reader) (n int64, err error)
}
```

`WriterTo`将数据写入到一个`Writer`。

```go
type WriterTo interface {
    WriteTo(w Writer) (n int64, err error)
}
```

`ReadAt`从指定偏移量处开始读取数据。

```go
type ReaderAt interface {
    ReadAt(p []byte, off int64) (n int, err error)
}
```

`WriterAt`将数据写入到指定偏移量处。

```go
type WriterAt interface {
    WriteAt(p []byte, off int64) (n int, err error)
}
```

`ByteReader`可以一次读取一个字节。

```go
type ByteReader interface {
    ReadByte() (c byte, err error)
}
```

`ByteScanner`可以通过`ReadByte`方法读取一个字节，然后通过`UnreadByte`将读取的字节还原，这样下一次调用`ReadByte`的时候，读到的是相同的字节。

```go
type ByteScanner interface {
    ByteReader
    UnreadByte() error
}
```

`ByteWriter`一次性写一个字节。

```go
type ByteWriter interface {
    WriteByte(c byte) error
}
```

`RuneReader`和`RuneScanner`与`ByteReader`和`ByteScanner`功能类似，不做赘述。

## WriteString

首先定义了一个私有接口`stringWriter`：

```go
type stringWriter interface {
    WriteString(s string) (n int, err error)
}
```

然后：

```go
func WriteString(w Writer, s string) (n int, err error) {
    // 如果w是一个stringWriter，即w有WriteString方法，则直接调用该方法
    if sw, ok := w.(stringWriter); ok {
        return sw.WriteString(s)
    }
    // 如果w不是stringWriter，则使用普通Writer的Write方法
    return w.Write([]byte(s))
}
```

## ReadAtLeast 和 ReadFull

`ReadAtLeast`读取至少为`min`个字节到`buf`中：

```go
func ReadAtLeast(r Reader, buf []byte, min int) (n int, err error) {
    // 源码比较简单，不做赘述
}
```

`ReadFull`读取恰好`len(buf)`个字节，实际上是调用了`ReadAtLeast`方法：

```go
func ReadFull(r Reader, buf []byte) (n int, err error) {
    return ReadAtLeast(r, buf, len(buf))
}
```

## Copy，CopyN，CopyBuffer

这几个方法最终依赖的都是一个私有方法`copyBuffer`，该方法会将一个输入流读到的数据写入到另一个输出流。

```go
func copyBuffer(dst Writer, src Reader, buf []byte) (written int64, err error) {
    // 如果src实现了WriterTo接口，则直接使用其WriteTo方法
    if wt, ok := src.(WriterTo); ok {
        return wt.WriteTo(dst)
    }
    // 如果dst实现了ReaderFrom接口，则直接使用其ReadFrom方法
    if rt, ok := dst.(ReaderFrom); ok {
        return rt.ReadFrom(src)
    }
    // 分配buf，默认每次最多拷贝32K
    if buf == nil {
        buf = make([]byte, 32*1024)
    }
    for {
        nr, er := src.Read(buf)
        if nr > 0 {
            // 将读到的数据写入到输出流
            nw, ew := dst.Write(buf[0:nr])
            if nw > 0 {
                written += int64(nw)
            }
            // 写出错，退出
            if ew != nil {
                err = ew
                break
            }
            // 数据量不一致，报错退出
            if nr != nw {
                err = ErrShortWrite
                break
            }
        }
        // 拷贝完毕
        if er == EOF {
            break
        }
        // 出错退出
        if er != nil {
            err = er
            break
        }
    }
    return written, err
}
```

`CopyBuffer`与`copyBuffer`基本一致，只不过需要预先分配缓冲区：

```go
func CopyBuffer(dst Writer, src Reader, buf []byte) (written int64, err error) {
    if buf != nil && len(buf) == 0 {
        panic("empty buffer in io.CopyBuffer")
    }
    return copyBuffer(dst, src, buf)
}
```

`Copy`直接调用了`copyBuffer`，会使用默认大小的缓冲区：

```go
func Copy(dst Writer, src Reader) (written int64, err error) {
    return copyBuffer(dst, src, nil)
}
```

`CopyN`与`Copy`类似，只不多限定了拷贝的数据量。对数据量的限制是通过一个`LimitedReader`来实现的。

```go
func CopyN(dst Writer, src Reader, n int64) (written int64, err error) {
    written, err = Copy(dst, LimitReader(src, n))
    if written == n {
        return n, nil
    }
    if written < n && err == nil {
        // src stopped early; must have been EOF.
        err = EOF
    }
    return
}
```

## LimitedReader

`LimitedReader`是对`Reader`的一层包装，限制了最多读取的数据量。

```go
type LimitedReader struct {
    R Reader // underlying reader
    N int64  // max bytes remaining
}
```

每次调用`Read`方法后，都会调整`N`的值：

```go
func (l *LimitedReader) Read(p []byte) (n int, err error) {
    if l.N <= 0 {
        return 0, EOF
    }
    if int64(len(p)) > l.N {
        p = p[0:l.N]
    }
    n, err = l.R.Read(p)
    l.N -= int64(n) // 调整N的值
    return
}
```

`LimitReader`方法可以创建一个`LimitedReader`：

```go
func LimitReader(r Reader, n int64) Reader { return &LimitedReader{r, n} }
```

