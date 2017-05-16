# sync

## WaitGroup

如下例子，将不会输出任何东西。因为main goroutine立即退出，因此两个goroutine都没有来得及执行。

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

为了得到两个goroutine输出，可以在main中通过`time.Sleep`来延迟程序结束：

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

也可以通过`channel`的方式：

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

不过，更方便的是通过`sync.WaitGroup`来实现：

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

`WaitGroup`可以等待一系列goroutine的执行完成。在main goroutine中通过`Add`方法指定等待的个数，在每个goroutine中调用`Done`方法标记该goroutine执行完成。`Wait`方法会等待，直到所有的goroutine执行结束。

## Locker

`Locker`是一个接口，有`Lock`和`Unlock`方法：

```go
type Locker interface {
    Lock()
    Unlock()
}
```
