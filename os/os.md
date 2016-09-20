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

