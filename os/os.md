# os

## FileMode

`FileMode`表示了一个文件的模式（是否为目录，是否为临时文件等）和权限（读、写、执行），本质上`FileMode`就是`uint32`类型，如下：

```go
type FileMode uint32
```

`FileMode`相关的一些常量定义：

```go
const (
    // The single letters are the abbreviations
    // used by the String method's formatting.
    ModeDir        FileMode = 1 << (32 - 1 - iota) // d: is a directory
    ModeAppend                                     // a: append-only
    ModeExclusive                                  // l: exclusive use
    ModeTemporary                                  // T: temporary file (not backed up)
    ModeSymlink                                    // L: symbolic link
    ModeDevice                                     // D: device file
    ModeNamedPipe                                  // p: named pipe (FIFO)
    ModeSocket                                     // S: Unix domain socket
    ModeSetuid                                     // u: setuid
    ModeSetgid                                     // g: setgid
    ModeCharDevice                                 // c: Unix character device, when ModeDevice is set
    ModeSticky                                     // t: sticky

    // Mask for the type bits. For regular files, none will be set.
    ModeType = ModeDir | ModeSymlink | ModeNamedPipe | ModeSocket | ModeDevice

    ModePerm FileMode = 0777 // Unix permission bits
)
```

即`ModeDir`为`1<<31 (0x80000000)`，`ModeAppend`为`1<<30 (0x40000000)`，以此类推。

### IsDir

```go
func (m FileMode) IsDir() bool {
    return m&ModeDir != 0
}
```

判断是否为目录。由于`ModeDir`只有目录为是1，因此通过`&`操作，如果`m`的目录位为1，则结果不为0，否则结果为0。

### IsRegular

```go
func (m FileMode) IsRegular() bool {
    return m&ModeType == 0
}
```

`ModeType`的定义为`ModeDir | ModeSymlink | ModeNamedPipe | ModeSocket | ModeDevice`，即表示为特殊文件类型（目录、软连接、管道、socket、设备）之一。如果`m&ModeType`为0，则说明`m`不属于特殊文件类型。

### Perm

获取权限位：

```go
func (m FileMode) Perm() FileMode {
    return m & ModePerm
}
```

### String

返回字符串形式，例如：

```go
fmt.Println(os.ModeDir.String())         // d---------
fmt.Println(os.ModePerm.String())        // -rwxrwxrwx
fmt.Println(os.ModeDir | os.ModeSymlink) // dL---------
```

## 环境变量

`os`包提供了对环境变量的一些操作，包括：

- func Environ() []string
- func Getenv(key string) string
- func LookupEnv(key string) (string, bool)
- func Setenv(key, value string) error
- func Unsetenv(key string) error
- func Clearenv()
- func ExpandEnv(s string) string

例如：

```go
key := "hello_go"
os.Setenv(key, "hello-go")
fmt.Println(os.Getenv(key))                           // hello-go
fmt.Println(os.LookupEnv(key))                        // hello-go true
fmt.Println(os.ExpandEnv("the value is ${hello_go}")) // the value is hello-go
fmt.Println(os.ExpandEnv("the value is $hello_go"))   // the value is hello-go
```

对于环境变量的获取以及修改操作都是调用了`syscall`包中的方法。

对于`ExpandEnv`方法，它是将一个字符串中的`${var}`或`$var`进行替换，例如会将`${path}`或`$path`替换为环境变量`path`的值。它实际上是调用了`Expand`方法：

```go
func ExpandEnv(s string) string {
    return Expand(s, Getenv)
}
```

`Expand`方法的签名如下：

```go
func Expand(s string, mapping func(string) string) string
```

它是将字符串`s`中的变量进行替换，替换规则由函数`mapping`来确定。例如：

```go
func mapping(s string) string {
    if s == "a" {
        return "b"
    } else {
        return "a"
    }
}

func main() {
    fmt.Println(os.Expand("${a} ${b}", mapping)) // b a
}
```

## methods (temp)

func Chdir(dir string) error
func Chmod(name string, mode FileMode) error
func Chown(name string, uid, gid int) error
func Chtimes(name string, atime time.Time, mtime time.Time) error


func Exit(code int)


func Getegid() int

func Geteuid() int
func Getgid() int
func Getgroups() ([]int, error)
func Getpagesize() int
func Getpid() int
func Getppid() int
func Getuid() int
func Getwd() (dir string, err error)
func Hostname() (name string, err error)
func IsExist(err error) bool
func IsNotExist(err error) bool
func IsPathSeparator(c uint8) bool
func IsPermission(err error) bool
func Lchown(name string, uid, gid int) error
func Link(oldname, newname string) error

func Mkdir(name string, perm FileMode) error
func MkdirAll(path string, perm FileMode) error
func NewSyscallError(syscall string, err error) error
func Readlink(name string) (string, error)
func Remove(name string) error
func RemoveAll(path string) error
func Rename(oldpath, newpath string) error
func SameFile(fi1, fi2 FileInfo) bool

func Symlink(oldname, newname string) error
func TempDir() string
func Truncate(name string, size int64) error
