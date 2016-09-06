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
