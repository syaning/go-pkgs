# strconv

## Atoi 和 Itoa

`Atoi`将string转成int，`Itoa`将int转成string。例如：

```go
fmt.Println(strconv.Atoi("123"))  // 123, nil
fmt.Println(strconv.Atoi("123a")) // 0, strconv.ParseInt: parsing "123a": invalid syntax
fmt.Println(strconv.Itoa(123))    // "123"
```

## format 和 parse

相关方法有：

- func FormatBool(b bool) string
- func FormatFloat(f float64, fmt byte, prec, bitSize int) string
- func FormatInt(i int64, base int) string
- func FormatUint(i uint64, base int) string
- func ParseBool(str string) (bool, error)
- func ParseFloat(s string, bitSize int) (float64, error)
- func ParseInt(s string, base int, bitSize int) (i int64, err error)
- func ParseUint(s string, base int, bitSize int) (uint64, error)