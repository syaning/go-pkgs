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
    udpAddr := &net.UDPAddr{
        IP:   net.ParseIP("127.0.0.1"),
        Port: 8080,
    }

    udpConn, err := net.ListenUDP("udp", udpAddr)
    if err != nil {
        fmt.Println("connection error")
        os.Exit(1)
    }
    defer udpConn.Close()

    for {
        data := make([]byte, 1024)
        n, addr, err := udpConn.ReadFromUDP(data)
        if err != nil {
            fmt.Println("error while reading data")
        }

        fmt.Printf("%s %s\n", addr, data[:n])
        udpConn.WriteToUDP([]byte("world"), addr)
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
