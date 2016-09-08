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

和包含相关的方法有：

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

###转换

和转换相关的方法有：

- func Title(s []byte) []byte
- func ToLower(s []byte) []byte
- func ToLowerSpecial(_case unicode.SpecialCase, s []byte) []byte
- func ToTitle(s []byte) []byte
- func ToTitleSpecial(_case unicode.SpecialCase, s []byte) []byte
- func ToUpper(s []byte) []byte
- func ToUpperSpecial(_case unicode.SpecialCase, s []byte) []byte

例如：

```go
s := []byte("heLLo 世界")
fmt.Println(string(bytes.Title(s)))   // HeLLo 世界
fmt.Println(string(bytes.ToLower(s))) // hello 世界
fmt.Println(string(bytes.ToTitle(s))) // HELLO 世界
fmt.Println(string(bytes.ToUpper(s))) // HELLO 世界
```

### trim

和trim相关的方法有：

- func Trim(s []byte, cutset string) []byte
- func TrimFunc(s []byte, f func(r rune) bool) []byte
- func TrimLeft(s []byte, cutset string) []byte
- func TrimLeftFunc(s []byte, f func(r rune) bool) []byte
- func TrimPrefix(s, prefix []byte) []byte
- func TrimRight(s []byte, cutset string) []byte
- func TrimRightFunc(s []byte, f func(r rune) bool) []byte
- func TrimSpace(s []byte) []byte
- func TrimSuffix(s, suffix []byte) []byte

例如：

```go
s := []byte("hello olleh")
fmt.Println(string(bytes.TrimLeft(s, "hel")))            // o olleh
fmt.Println(string(bytes.TrimRight(s, "hel")))           // hello o
fmt.Println(string(bytes.Trim(s, "hel")))                // o o
fmt.Println(string(bytes.TrimPrefix(s, []byte("hel"))))  // lo olleh
fmt.Println(string(bytes.TrimSuffix(s, []byte("lleh")))) // hello o
```

其中最基本的两个方法是`TrimLeftFunc`和`TrimRightFunc`，`TrimLeft`，`TrimRight`，`TrimFunc`都是基于这两个方法。例如：

```go
func TrimFunc(s []byte, f func(r rune) bool) []byte {
    return TrimRightFunc(TrimLeftFunc(s, f), f)
}
```

`Trim`和`TrimSpace`都是基于`TrimFunc`方法。

`TrimPrefix`和`TrimSuffix`其实都是简单使用了切片操作。

### split 和 join

相关方法有：

- func Split(s, sep []byte) [][]byte
- func SplitAfter(s, sep []byte) [][]byte
- func SplitAfterN(s, sep []byte, n int) [][]byte
- func SplitN(s, sep []byte, n int) [][]byte
- func Fields(s []byte) [][]byte
- func FieldsFunc(s []byte, f func(rune) bool) [][]byte
- func Join(s [][]byte, sep []byte) []byte

例如：

```go
s := []byte("hello,world,welcome")

arr := bytes.Split(s, []byte(","))
for _, a := range arr {
    fmt.Print(string(a), " ")
}
// hello world welcome

arr = bytes.SplitAfter(s, []byte(","))
for _, a := range arr {
    fmt.Print(string(a), " ")
}
// hello, world, welcome
```

`SplitAfter`相比于`Split`，会包含分隔符。

`SplitN`和`SplitAfterN`与`Split`和`SplitAfter`相似，只不过限制了最大的切分个数，超过部分不再切分。例如：

```go
s := []byte("hello,world,welcome")

arr := bytes.SplitN(s, []byte(","), 2)
for _, a := range arr {
    fmt.Print(string(a), " ")
}
// hello world,welcome
```

`Fields`是通过连续的空字符来切分，例如：

```go
s := []byte("  hello  world   welcome ")
arr := bytes.Fields(s)
for _, a := range arr {
    fmt.Print(string(a), " ")
}
// hello world welcome
```

`FieldsFunc`则是通过一个函数来检测切分条件，实际上，`Fields`是调用了`FieldsFunc`：

```go
func Fields(s []byte) [][]byte {
    return FieldsFunc(s, unicode.IsSpace)
}
```

`Join`用于连接操作，例如：

```go
s := [][]byte{
    []byte("hello"),
    []byte("world"),
    []byte("welcome"),
}
fmt.Println(string(bytes.Join(s, []byte(", "))))
// hello, world, welcome
```

### 其它操作

- func Map(mapping func(r rune) rune, s []byte) []byte
- func Repeat(b []byte, count int) []byte
- func Replace(s, old, new []byte, n int) []byte
- func Runes(s []byte) []rune

例如：

```go
s := []byte("hello")
fmt.Println(string(bytes.Repeat(s, 3)))                             // hellohellohello
fmt.Println(string(bytes.Replace(s, []byte("l"), []byte("L"), 1)))  // heLlo
fmt.Println(string(bytes.Replace(s, []byte("l"), []byte("L"), -1))) // heLLo

s = []byte("hello 世界")
fmt.Println(s)              // [104 101 108 108 111 32 228 184 150 231 149 140]
fmt.Println(bytes.Runes(s)) // [104 101 108 108 111 32 19990 30028]

f := func(r rune) rune { return r + 1 }
fmt.Println(string(bytes.Map(f, []byte("abcdefg")))) // bcdefgh
```

## Buffer

## Reader