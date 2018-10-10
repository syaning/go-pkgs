# encoding/base32

关于 base32 的信息查看 [wiki](https://en.wikipedia.org/wiki/Base32) 和 [RFC 4648](https://tools.ietf.org/html/rfc4648)。

## 两个 Encoding

- StdEncoding
- HexEncoding

例如：

```go
package main

import (
    "encoding/base32"
    "fmt"
)

func main() {
    msg := []byte("Hello world. 你好，世界！")

    encoded := base32.StdEncoding.EncodeToString(msg)
    fmt.Println(encoded)
    // JBSWY3DPEB3W64TMMQXCBZF5UDS2LPPPXSGOJOEW46KYZ354QE======

    decoded, _ := base32.StdEncoding.DecodeString(encoded)
    fmt.Println(string(decoded))
    // Hello world. 你好，世界！

    encoded = base32.HexEncoding.EncodeToString(msg)
    fmt.Println(encoded)
    // 91IMOR3F41RMUSJCCGN21P5TK3IQBFFFNI6E9E4MSUAOPRTSG4======

    decoded, _ = base32.HexEncoding.DecodeString(encoded)
    fmt.Println(string(decoded))
    // Hello world. 你好，世界！
}
```
