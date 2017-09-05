# net

## UDP

server:

```go
package main

import (
    "fmt"
    "net"
    "os"
)

func main() {
    addr := &net.UDPAddr{
        IP:   net.ParseIP("127.0.0.1"),
        Port: 8080,
    }

    conn, err := net.ListenUDP("udp", addr)
    if err != nil {
        fmt.Println("connection error")
        os.Exit(1)
    }
    defer conn.Close()

    fmt.Printf("run UDP server on %s\n", conn.LocalAddr())

    for {
        data := make([]byte, 1024)
        n, remoteAddr, err := conn.ReadFromUDP(data)
        if err != nil {
            fmt.Println("error while reading data")
        }

        fmt.Printf("%s %s\n", remoteAddr, data[:n])
        conn.WriteToUDP([]byte("world"), remoteAddr)
    }
}
```

client:

```go
package main

import (
    "fmt"
    "net"
)

func main() {
    addr := &net.UDPAddr{
        IP:   net.ParseIP("127.0.0.1"),
        Port: 8080,
    }

    conn, err := net.DialUDP("udp", nil, addr)
    if err != nil {
        fmt.Println("dial error")
    }
    defer conn.Close()

    conn.Write([]byte("hello"))

    data := make([]byte, 1024)
    n, err := conn.Read(data)
    if err != nil {
        fmt.Println("read error")
    }
    fmt.Printf("%s\n", data[:n])
}
```

## TCP

server:

```go
package main

import (
    "fmt"
    "net"
    "os"
)

func main() {
    addr := &net.TCPAddr{
        IP:   net.ParseIP("127.0.0.1"),
        Port: 8080,
    }

    ln, err := net.ListenTCP("tcp", addr)
    if err != nil {
        fmt.Println("connection error")
        os.Exit(1)
    }
    defer ln.Close()

    fmt.Printf("run TCP server on %s\n", ln.Addr())

    for {
        conn, err := ln.Accept()
        if err != nil {
            fmt.Println("accept error")
            os.Exit(1)
        }

        go handleRequest(conn)
    }
}

func handleRequest(conn net.Conn) {
    data := make([]byte, 1024)
    n, err := conn.Read(data)
    if err != nil {
        fmt.Println("read error")
    }
    fmt.Printf("%s\n", data[:n])
    conn.Write([]byte("world"))
    conn.Close()
}
```

client:

```go
package main

import (
    "fmt"
    "net"
)

func main() {
    addr := &net.TCPAddr{
        IP:   net.ParseIP("127.0.0.1"),
        Port: 8080,
    }

    conn, err := net.DialTCP("tcp", nil, addr)
    if err != nil {
        fmt.Println("dial error")
    }
    defer conn.Close()

    conn.Write([]byte("hello"))

    data := make([]byte, 1024)
    n, err := conn.Read(data)
    if err != nil {
        fmt.Println("read error")
    }
    fmt.Printf("%s\n", data[:n])
}
```
