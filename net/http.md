# http

## 辅助方法

### CanonicalHeaderKey

与`textproto.CanonicalMIMEHeaderKey`效果相同。

## Handler 和 HandlerFunc

`Handler`是一个`interface`：

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

`HandlerFunc`是一类函数，它的参数列表与`Handler`的`ServeHTTP`方法的参数列表相同：

```go
type HandlerFunc func(ResponseWriter, *Request)
```

并且它实现了`ServeHTTP`方法：

```go
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
    f(w, r)
}
```

因此，`HandlerFunc`的主要作用就是将一个普通函数包装成一个`Handler`：

```go
var f = func(w http.ResponseWriter, r *http.Request) {}
var g interface{} = http.HandlerFunc(f)
_, ok := g.(http.Handler)
fmt.Println(ok) // true
```

## Header

与`textproto.MIMEHeader`类似，本质上也是一个`map[string][]string`。同样拥有`Add`，`Set`，`Get`，`Del`方法，此外还有`Write`和`WriteSubset`方法。

```go
h := http.Header{}
h.Set("Content-Type", "application/json")
h.Add("Accept-Encoding", "gzip")
h.Add("Accept-Encoding", "deflate")
h.Set("Cache-Control", "no-cache")

h.Write(os.Stdout)
// Accept-Encoding: gzip
// Accept-Encoding: deflate
// Cache-Control: no-cache
// Content-Type: application/json

h.WriteSubset(os.Stdout, map[string]bool{
    "Accept-Encoding": true,
})
// Cache-Control: no-cache
// Content-Type: application/json
```
