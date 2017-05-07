# http

## 辅助方法

### CanonicalHeaderKey

与`net/textproto.CanonicalMIMEHeaderKey`效果相同。

## Header

与`net/textproto.MIMEHeader`类似，本质上也是一个`map[string][]string`。同样拥有`Add`，`Set`，`Get`，`Del`方法，此外还有`Write`和`WriteSubset`方法。

```go
h := make(http.Header)
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
