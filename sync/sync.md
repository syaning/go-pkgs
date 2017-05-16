# sync

## WaitGroup

```go
package main

import (
    "fmt"
)

func main() {
    go func() {
        fmt.Println(1)
    }()

    go func() {
        fmt.Println(2)
    }()
}
```

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    go func() {
        fmt.Println(1)
    }()

    go func() {
        fmt.Println(2)
    }()

    time.Sleep(2 * time.Second)
}
```

```go
package main

import (
    "fmt"
)

func main() {
    c := make(chan struct{})

    go func() {
        fmt.Println(1)
        c <- struct{}{}
    }()

    go func() {
        fmt.Println(2)
        c <- struct{}{}
    }()

    for i := 0; i < 2; i++ {
        <-c
    }
}
```

```go
package main

import (
    "fmt"
    "sync"
)

func main() {
    var wg sync.WaitGroup
    wg.Add(2)

    go func() {
        fmt.Println(1)
        wg.Done()
    }()

    go func() {
        fmt.Println(2)
        wg.Done()
    }()

    wg.Wait()
}
```
