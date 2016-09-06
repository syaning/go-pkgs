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

```go
type ReaderFrom interface {
    ReadFrom(r Reader) (n int64, err error)
}
```

`ReaderFrom`从一个`Reader`读取数据。

```go
type WriterTo interface {
    WriteTo(w Writer) (n int64, err error)
}
```

`WriterTo`将数据写入到一个`Writer`。

```go
type ReaderAt interface {
    ReadAt(p []byte, off int64) (n int, err error)
}
```

`ReadAt`从指定偏移量处开始读取数据。

```go
type WriterAt interface {
    WriteAt(p []byte, off int64) (n int, err error)
}
```

`WriterAt`将数据写入到指定偏移量处。

```go
type ByteReader interface {
    ReadByte() (c byte, err error)
}
```

`ByteReader`可以一次读取一个字节。

```go
type ByteScanner interface {
    ByteReader
    UnreadByte() error
}
```

`ByteScanner`可以通过`ReadByte`方法读取一个字节，然后通过`UnreadByte`将读取的字节还原，这样下一次调用`ReadByte`的时候，读到的是相同的字节。

`RuneReader`和`RuneScanner`与`ByteReader`和`ByteScanner`功能类似。

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
