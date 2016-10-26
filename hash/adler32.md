# adler32

Adler-32是一种校验和算法，详情参考[wiki](https://en.wikipedia.org/wiki/Adler-32)。

通过`CheckSum`方法可以计算校验和，例如：

```go
sum := adler32.Checksum([]byte("Wikipedia"))
fmt.Printf("%x", sum) // 11e60398
```

也可以通过`New`方法来生成一个`hash.Hash32`来计算校验和，例如：

```go
h := adler32.New()
h.Write([]byte("Wiki"))
h.Write([]byte("pedia"))
fmt.Printf("%x", h.Sum32()) // 11e60398
```

由于`hahs.Hash32`接口实现了`io.Writer`接口，因此有`Write`方法。