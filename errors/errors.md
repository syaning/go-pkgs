# errors

errors定义了一个非常简单的struct：

```go
type errorString struct {
    s string
}
```

通过`New`方法可以创建新的error，例如：

```go
err := errors.New("something is wrong")
```
