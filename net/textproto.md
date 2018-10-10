# net/textproto

## 辅助方法

### CanonicalMIMEHeaderKey

该方法用来将Header Key处理为标准化形式，如果输入中有不合法字符，则直接返回原字符。

```go
s := textproto.CanonicalMIMEHeaderKey("accept-encoding")
fmt.Println(s) // "Accept-Encoding"

s = textproto.CanonicalMIMEHeaderKey("accept-encoding ")
fmt.Println(s) // "accept-encoding "
```

## MIMEHeader

`MIMEHeader`实际上是一个`map`：

```go
type MIMEHeader map[string][]string
```

有如下方法：

- Add(key, value string)
- Set(key, value string)
- Get(key string) string：返回第一个值，如果需要返回多个值，直接使用map来取值
- Del(key string)

这几个方法都会先使用`CanonicalMIMEHeaderKey`对`key`进行标准化处理。
