# crypto/md5

## Sum

```go
package main

import (
    "crypto/md5"
    "encoding/hex"
    "fmt"
)

func main() {
    data := []byte("Hello world")
    sum := md5.Sum(data)
    fmt.Println(hex.EncodeToString(sum[:]))
    // 3e25960a79dbc69b674cd4ec67a72c62
}
```

## New

```go
package main

import (
    "crypto/md5"
    "encoding/hex"
    "fmt"
    "io"
)

func main() {
    h := md5.New()
    io.WriteString(h, "Hello world")
    sum := h.Sum(nil)
    fmt.Println(hex.EncodeToString(sum[:]))
    // 3e25960a79dbc69b674cd4ec67a72c62
}
```

