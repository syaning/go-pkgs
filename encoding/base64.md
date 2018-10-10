# encoding/base64

## 四个 Encoding

- StdEncoding：常规编码
- URLEncoding：URL safe 编码
- RawStdEncoding：常规编码，末尾不补 =
- RawURLEncoding：URL safe 编码，末尾不补 =

其中，URL safe 编码，相当于是替换掉字符串中的特殊字符，`+` 和 `/`。更多关于 base64 的信息查看 [wiki](https://en.wikipedia.org/wiki/Base64) 和 [RFC 4648](https://tools.ietf.org/html/rfc4648)。

下面是例子：

```go
package main

import (
    "encoding/base64"
    "fmt"
)

func main() {
    msg := []byte("Hello world. 你好，世界！")

    encoded := base64.StdEncoding.EncodeToString(msg)
    fmt.Println(encoded)
    // SGVsbG8gd29ybGQuIOS9oOWlve+8jOS4lueVjO+8gQ==

    decoded, _ := base64.StdEncoding.DecodeString(encoded)
    fmt.Println(string(decoded))
    // Hello world. 你好，世界！

    encoded = base64.RawStdEncoding.EncodeToString(msg)
    fmt.Println(encoded)
    // SGVsbG8gd29ybGQuIOS9oOWlve+8jOS4lueVjO+8gQ

    decoded, _ = base64.RawStdEncoding.DecodeString(encoded)
    fmt.Println(string(decoded))
    // Hello world. 你好，世界！

    encoded = base64.URLEncoding.EncodeToString(msg)
    fmt.Println(encoded)
    // SGVsbG8gd29ybGQuIOS9oOWlve-8jOS4lueVjO-8gQ==

    decoded, _ = base64.URLEncoding.DecodeString(encoded)
    fmt.Println(string(decoded))
    // Hello world. 你好，世界！

    encoded = base64.RawURLEncoding.EncodeToString(msg)
    fmt.Println(encoded)
    // SGVsbG8gd29ybGQuIOS9oOWlve-8jOS4lueVjO-8gQ

    decoded, _ = base64.RawURLEncoding.DecodeString(encoded)
    fmt.Println(string(decoded))
    // Hello world. 你好，世界！
}
```
