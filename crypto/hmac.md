# crypto/hmac

```go
package main

import (
    "crypto/hmac"
    "crypto/sha256"
    "encoding/hex"
    "fmt"
    "io"
)

func main() {
    mac := hmac.New(sha256.New, []byte("secret"))
    io.WriteString(mac, "Hello world")
    sum := mac.Sum(nil)
    fmt.Println(hex.EncodeToString(sum[:]))
    // 0d5548fb7450e619b0753725068707519ed41cd212b0500bc20427e3ef66e08e
}
```
