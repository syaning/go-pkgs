# log

## Logger

通过`New(out io.Writer, prefix string, flag int)`可以创建一个`Logger`，其中：

- `out`：日志输出目标
- `prefix`：日志数据前缀
- `flag`：标志位，控制日志的输出格式

其中`flag`可取值为：

```go
const (
    // Bits or'ed together to control what's printed.
    // There is no control over the order they appear (the order listed
    // here) or the format they present (as described in the comments).
    // The prefix is followed by a colon only when Llongfile or Lshortfile
    // is specified.
    // For example, flags Ldate | Ltime (or LstdFlags) produce,
    //  2009/01/23 01:23:23 message
    // while flags Ldate | Ltime | Lmicroseconds | Llongfile produce,
    //  2009/01/23 01:23:23.123123 /a/b/c/d.go:23: message
    Ldate         = 1 << iota     // the date in the local time zone: 2009/01/23
    Ltime                         // the time in the local time zone: 01:23:23
    Lmicroseconds                 // microsecond resolution: 01:23:23.123123.  assumes Ltime.
    Llongfile                     // full file name and line number: /a/b/c/d.go:23
    Lshortfile                    // final file name element and line number: d.go:23. overrides Llongfile
    LUTC                          // if Ldate or Ltime is set, use UTC rather than the local time zone
    LstdFlags     = Ldate | Ltime // initial values for the standard logger
)
```

下面是一个例子，首先是输出日志到标准输出，然后更改设置，输出到文件：

```go
logger := log.New(os.Stdout, "my logger: ", log.LstdFlags)

fmt.Println(logger.Prefix()) // "my logger: "
fmt.Println(logger.Flags())  // 3

logger.Println("hello world") // my logger: 2017/05/19 15:22:17 hello world

file, err := os.OpenFile("data.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
if err != nil {
    panic("open log file error")
}
defer file.Close()

logger.SetOutput(file)
logger.SetPrefix("hello: ")
logger.SetFlags(log.Lmicroseconds | log.Lshortfile)

logger.Println("hello world") // hello: 15:22:17.050889 main.go:27: hello world
```

`Logger`的输出方式有三种:

- Print: Print, Printf, Println
- Fatal: Fatal, Fatalf, Fatalln
- Panic: Panic, Panicf, Panicln

其中Fatal相当于是Print之后跟了一个`os.Exit(1)`操作，Panic相当于是Print后跟了一个`panic()`。

这三种输出方式，本质上都是调用了`Output`方法，一般我们不会主动调用该方法。

## 全局Logger

logger模块中有一个非导出的全局默认`Logger`：

```go
var std = New(os.Stderr, "", LstdFlags)
```

logger模块的全局方法，实际上就是调用了`std`的相应方法。