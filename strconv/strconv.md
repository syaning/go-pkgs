# strconv

## Atoi 和 Itoa

`Atoi`将string转成int，`Itoa`将int转成string。例如：

```go
fmt.Println(strconv.Atoi("123"))  // 123, nil
fmt.Println(strconv.Atoi("123a")) // 0, strconv.ParseInt: parsing "123a": invalid syntax
fmt.Println(strconv.Itoa(123))    // 123
```

## format 和 parse

format和parse是两组相反的方法，用于string和其它类型之间的相互转化。相关方法有：

- func FormatBool(b bool) string
- func FormatFloat(f float64, fmt byte, prec, bitSize int) string
- func FormatInt(i int64, base int) string
- func FormatUint(i uint64, base int) string
- func ParseBool(str string) (bool, error)
- func ParseFloat(s string, bitSize int) (float64, error)
- func ParseInt(s string, base int, bitSize int) (i int64, err error)
- func ParseUint(s string, base int, bitSize int) (uint64, error)

format相关方法将其它类型的数据转换为string，例如：

```go
fmt.Println(strconv.FormatBool(true))                 // true
fmt.Println(strconv.FormatFloat(3.1415, 'E', -1, 64)) // 3.1415E+00
fmt.Println(strconv.FormatInt(-42, 16))               // -2a
fmt.Println(strconv.FormatUint(42, 16))               // 2a
```

parse相关方法将string转为其它类型的数据，例如：

```go
fmt.Println(strconv.ParseBool("tRue"))        // true <nil>
fmt.Println(strconv.ParseFloat("3.1415", 32)) // 3.1414999961853027 <nil>
fmt.Println(strconv.ParseFloat("3.1415", 64)) // 3.1415 <nil>
fmt.Println(strconv.ParseInt("-42", 10, 32))  // -42 <nil>
fmt.Println(strconv.ParseInt("11011", 2, 32)) // 27 <nil>
fmt.Println(strconv.ParseInt("0xff", 0, 32))  // 255 <nil>
fmt.Println(strconv.ParseUint("42", 16, 32))  // 66 <nil>
```

对于`ParseBool`，遵循如下规则：

- 返回`true`：`"1"`，`"t"`，`"T"`，`"TRUE"`，`"true"`，`"True"`
- 返回`false`：`"0"`，`"f"`，`"F"`，`"FALSE"`，`"false"`，`"False"`
- 其它情况报错

对于`ParseFloat`，`bitSize`取值为`32`或`64`。

对于`ParseInt`，`base`取值在2~36之间，如果`base`为0，那么会根据第一个参数字符串的前缀来决定进制：`0`为8进制，`0x`为16进制，其它情况为10进制。第三个参数`bitSize`可以为`0`(int)，`8`(int8)，`16`(int16)，`32`(int32)，`64`(int64)。

`ParseUint`与`ParseInt`类似。

## IsGraphic 和 IsPrint

## quote 和 unquote

相关方法有：

- func Quote(s string) string
- func QuoteRune(r rune) string
- func QuoteRuneToASCII(r rune) string
- func QuoteRuneToGraphic(r rune) string
- func QuoteToASCII(s string) string
- func QuoteToGraphic(s string) string
- func Unquote(s string) (string, error)
- func UnquoteChar(s string, quote byte) (value rune, multibyte bool, tail string, err error)

quote相关方法返回一个用引号引着的字符串，unquote与quote行为相反，例如：

```go
fmt.Println(strconv.Quote(`"Hello   ☺"`))        // "\"Hello\t☺\""
fmt.Println(strconv.QuoteRune('☺'))            // '☺'
fmt.Println(strconv.QuoteRuneToASCII('☺'))     // '\u263a'
fmt.Println(strconv.QuoteToASCII(`"Hello    ☺"`)) // "\"Hello\t\u263a\""
fmt.Println(strconv.Unquote(`"\"Hello\t☺\""`)) // "Hello    ☺" <nil>
```

## append

append主要功能是将数据添加到slice中，相关方法有：

- func AppendBool(dst []byte, b bool) []byte
- func AppendFloat(dst []byte, f float64, fmt byte, prec, bitSize int) []byte
- func AppendInt(dst []byte, i int64, base int) []byte
- func AppendQuote(dst []byte, s string) []byte
- func AppendQuoteRune(dst []byte, r rune) []byte
- func AppendQuoteRuneToASCII(dst []byte, r rune) []byte
- func AppendQuoteRuneToGraphic(dst []byte, r rune) []byte
- func AppendQuoteToASCII(dst []byte, s string) []byte
- func AppendQuoteToGraphic(dst []byte, s string) []byte
- func AppendUint(dst []byte, i uint64, base int) []byte

例如：

```go
dst := []byte("hello ")
fmt.Println(string(strconv.AppendBool(dst, true)))     // hello true
fmt.Println(string(strconv.AppendInt(dst, -42, 16)))   // hello -2a
fmt.Println(string(strconv.AppendQuote(dst, "world"))) // hello "world"
```
