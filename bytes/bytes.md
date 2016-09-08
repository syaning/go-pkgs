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
fmt.Println(bytes.IndexRune(s, '界'))       // 9
```

### 包含

和包含功能相关的方法有：

- func Contains(b, subslice []byte) bool
- func ContainsAny(b []byte, chars string) bool
- func ContainsRune(b []byte, r rune) bool
- func Count(s, sep []byte) int
- func HasPrefix(s, prefix []byte) bool
- func HasSuffix(s, suffix []byte) bool

例如：

```go
s := []byte("Hello 世界")
fmt.Println(bytes.Contains(s, []byte("llo"))) // true
fmt.Println(bytes.ContainsAny(s, "llo"))      // true
fmt.Println(bytes.ContainsRune(s, '世'))       // true
fmt.Println(bytes.Count(s, []byte("llo")))    // 1
fmt.Println(bytes.HasPrefix(s, []byte("llo"))) // false
fmt.Println(bytes.HasSuffix(s, []byte("世界")))  // true
```

在源码中，`Contains[Any/Rune]`是通过`Index[Any/Rune]`来实现的，例如：

```go
func ContainsAny(b []byte, chars string) bool {
    return IndexAny(b, chars) >= 0
}
```

`HasPrefix`和`HasSuffix`是通过`Equal`来实现的，例如：

```go
func HasPrefix(s, prefix []byte) bool {
    return len(s) >= len(prefix) && Equal(s[0:len(prefix)], prefix)
}
```

## Buffer

## Reader