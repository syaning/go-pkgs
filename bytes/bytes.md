# bytes

## 基本操作

### 比较

和比较相关的方法有：

- func Equal(a, b []byte) bool
- func EqualFold(s, t []byte) bool
- func Compare(a, b []byte) int

其中`Equal`和`Compare`是使用汇编来实现的。

例如：

```go
a := []byte("hello")
b := []byte("world")
fmt.Println(bytes.Equal(a, b))   // false
fmt.Println(bytes.Compare(a, b)) // -1
fmt.Println(bytes.Compare(b, a)) // 1
```

`EqualFold`会忽略大小写，同时会将特殊字符进行转换。例如：

```go
a := []byte("hello ϕ")
b := []byte("Hello Φ")
fmt.Println(bytes.EqualFold(a, b)) // true
```

### index

和index相关的方法有：

- func Index(s, sep []byte) int
- func IndexAny(s []byte, chars string) int
- func IndexByte(s []byte, c byte) int
- func IndexFunc(s []byte, f func(r rune) bool) int
- func IndexRune(s []byte, r rune) int
- func LastIndex(s, sep []byte) int
- func LastIndexAny(s []byte, chars string) int
- func LastIndexByte(s []byte, c byte) int
- func LastIndexFunc(s []byte, f func(r rune) bool) int

例如：

```go
s := []byte("Hello 世界")
fmt.Println(bytes.Index(s, []byte("llo"))) // 2
fmt.Println(bytes.IndexAny(s, "ole"))      // 1
fmt.Println(bytes.IndexByte(s, 'l'))       // 2
fmt.Println(bytes.IndexRune(s, '界'))      // 9
```

### 包含

和包含功能相关的方法有：

- func Contains(b, subslice []byte) bool
- func ContainsAny(b []byte, chars string) bool
- func ContainsRune(b []byte, r rune) bool
- func Count(s, sep []byte) int

例如：

```go

```

## Buffer

## Reader