# reflect

## Kind

`Kind` 用来表示具体的类型，定义如下：

```go
type Kind uint

const (
    Invalid Kind = iota
    Bool
    Int
    Int8
    Int16
    Int32
    Int64
    Uint
    Uint8
    Uint16
    Uint32
    Uint64
    Uintptr
    Float32
    Float64
    Complex64
    Complex128
    Array
    Chan
    Func
    Interface
    Map
    Ptr
    Slice
    String
    Struct
    UnsafePointer
)
```

`Kind` 实现了 `Stringer` 接口，因此打印出来的时候是字符串而不是数字。

```go
var kindNames = []string{
    Invalid:       "invalid",
    Bool:          "bool",
    Int:           "int",
    Int8:          "int8",
    Int16:         "int16",
    Int32:         "int32",
    Int64:         "int64",
    Uint:          "uint",
    Uint8:         "uint8",
    Uint16:        "uint16",
    Uint32:        "uint32",
    Uint64:        "uint64",
    Uintptr:       "uintptr",
    Float32:       "float32",
    Float64:       "float64",
    Complex64:     "complex64",
    Complex128:    "complex128",
    Array:         "array",
    Chan:          "chan",
    Func:          "func",
    Interface:     "interface",
    Map:           "map",
    Ptr:           "ptr",
    Slice:         "slice",
    String:        "string",
    Struct:        "struct",
    UnsafePointer: "unsafe.Pointer",
}
```

## Type
