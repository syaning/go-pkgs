# hex

```go
package main

import (
    "encoding/hex"
    "fmt"
)

func main() {
    msg := []byte("Hello 世界")

    encoded := hex.EncodeToString(msg)
    fmt.Println(encoded)
    // 48656c6c6f20e4b896e7958c

    decoded, _ := hex.DecodeString(encoded)
    fmt.Println(string(decoded))
    // Hello 世界
}
```
