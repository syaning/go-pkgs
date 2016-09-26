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

## errors

变量有：

```go
var (
    ErrInvalid    = errors.New("invalid argument") // methods on File will return this error when the receiver is nil
    ErrPermission = errors.New("permission denied")
    ErrExist      = errors.New("file already exists")
    ErrNotExist   = errors.New("file does not exist")
)
```

类型有：

```go
type PathError struct {
    Op   string
    Path string
    Err  error
}

type LinkError struct {
    Op  string
    Old string
    New string
    Err error
}

type SyscallError struct {
    Syscall string
    Err     error
}
```

通过`NewSyscallError(syscall string, err error)`可以新建一个系统调用错误。

其它相关方法有：

- func IsExist(err error) bool
- func IsNotExist(err error) bool
- func IsPermission(err error) bool

分别用来判断一个错误是否是“文件已经存在”、“文件不存在”、“权限错误”，例如：

```go
fmt.Println(os.IsExist(os.ErrExist))           // true
fmt.Println(os.IsNotExist(os.ErrNotExist))     // true
fmt.Println(os.IsPermission(os.ErrPermission)) // true
```

## File

os包提供了平台无关的文件操作。即对于不同的操作系统，它有着不同的具体实现，但是对外的接口是一致的。

文件的创建和打开相关的方法如下：

- func Create(name string) (*File, error)
- func NewFile(fd uintptr, name string) *File
- func Open(name string) (*File, error)
- func OpenFile(name string, flag int, perm FileMode) (*File, error)

其中，`NewFile`是根据文件描述符和文件名来返回一个指针，实际上并没有真正创建文件。

`OpenFile`根据文件名、flag和权限来打开或者创建文件，并通过`NewFile`来返回文件指针。其中flag可取值为：

```go
// Flags to OpenFile wrapping those of the underlying system. Not all
// flags may be implemented on a given system.
const (
    O_RDONLY int = syscall.O_RDONLY // open the file read-only.
    O_WRONLY int = syscall.O_WRONLY // open the file write-only.
    O_RDWR   int = syscall.O_RDWR   // open the file read-write.
    O_APPEND int = syscall.O_APPEND // append data to the file when writing.
    O_CREATE int = syscall.O_CREAT  // create a new file if none exists.
    O_EXCL   int = syscall.O_EXCL   // used with O_CREATE, file must not exist
    O_SYNC   int = syscall.O_SYNC   // open for synchronous I/O.
    O_TRUNC  int = syscall.O_TRUNC  // if possible, truncate file when opened.
)
```

`Create`调用了`OpenFile`，来创建一个文件：

```go
// 以读写模式来创建新文件
// 如果文件已经存在，则会清空原有文件
func Create(name string) (*File, error) {
    return OpenFile(name, O_RDWR|O_CREATE|O_TRUNC, 0666)
}
```

`Open`调用了`OpenFile`，以只读模式打开一个文件：

```go
// 以只读模式打开文件
// 如果文件不存在，会报错
func Open(name string) (*File, error) {
    return OpenFile(name, O_RDONLY, 0)
}
```

### read

- func (f *File) Read(b []byte) (n int, err error)
- func (f *File) ReadAt(b []byte, off int64) (n int, err error)
- func (f *File) Readdir(n int) ([]FileInfo, error)
- func (f *File) Readdirnames(n int) (names []string, err error)

如果文件是一个目录的话，`Readdir(n int)`可以读取该目录下文件的信息。如果参数`n`大于0，则会返回前`n`个文件的信息，否则返回所有子文件的信息。

`Readdirnames`会返回子文件的文件名，参数限定和`Readdir`一致。

### write

- func (f *File) Write(b []byte) (n int, err error)
- func (f *File) WriteAt(b []byte, off int64) (n int, err error)
- func (f *File) WriteString(s string) (n int, err error)

### 其它操作

- func (f *File) Chdir() error
- func (f *File) Chmod(mode FileMode) error
- func (f *File) Chown(uid, gid int) error
- func (f *File) Close() error
- func (f *File) Fd() uintptr
- func (f *File) Name() string
- func (f *File) Sync() error
- func (f *File) Stat() (FileInfo, error)
- func (f *File) Seek(offset int64, whence int) (ret int64, err error)
- func (f *File) Truncate(size int64) error

其中`Sync`方法会将写入该文件的数据从内存持久化到磁盘上。

## 其它系统调用

- func Getpid() int
- func Getppid() int
- func Getgid() int
- func Getegid() int
- func Getuid() int
- func Geteuid() int
- func Getgroups() ([]int, error)
- func Exit(code int)
- func Getpagesize() int
- func Getwd() (dir string, err error)
- func Hostname() (name string, err error)

## 其它方法

- func Chdir(dir string) error
- func Chmod(name string, mode FileMode) error
- func Chown(name string, uid, gid int) error
- func Chtimes(name string, atime time.Time, mtime time.Time) error
- func IsPathSeparator(c uint8) bool
- func Lchown(name string, uid, gid int) error
- func Link(oldname, newname string) error
- func Mkdir(name string, perm FileMode) error
- func MkdirAll(path string, perm FileMode) error
- func Readlink(name string) (string, error)
- func Remove(name string) error
- func RemoveAll(path string) error
- func Rename(oldpath, newpath string) error
- func SameFile(fi1, fi2 FileInfo) bool
- func Symlink(oldname, newname string) error
- func TempDir() string
- func Truncate(name string, size int64) error
