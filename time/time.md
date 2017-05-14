# time

## Month

`Month`为`int`值，1到12分别表示12个月：

```go
type Month int

const (
    January Month = 1 + iota
    February
    March
    April
    May
    June
    July
    August
    September
    October
    November
    December
)
```

## Weekday

`Weekday`为`int`值，0到6分别表示周日到周六：

```go
type Weekday int

const (
    Sunday Weekday = iota
    Monday
    Tuesday
    Wednesday
    Thursday
    Friday
    Saturday
)
```

## Duration

`Duration`表示时间间隔，为`int64`类型，单位为纳秒。相关常量有：

```go
const (
    Nanosecond  Duration = 1
    Microsecond          = 1000 * Nanosecond
    Millisecond          = 1000 * Microsecond
    Second               = 1000 * Millisecond
    Minute               = 60 * Second
    Hour                 = 60 * Minute
)
```

例如：

```go
d := time.Duration(1*time.Hour + 2*time.Minute + 3*time.Second + 45678)
fmt.Println(d.String())      // 1h2m3.000045678s
fmt.Println(d.Hours())       // 1.034166679355
fmt.Println(d.Minutes())     // 62.0500007613
fmt.Println(d.Seconds())     // 3723.000045678
fmt.Println(d.Nanoseconds()) // 3723000045678
```

`Since`和`Until`方法可以返回某一时刻与当前时刻的时间间隔。例如：

```go
start := time.Now()
time.Sleep(5 * time.Second)

d := time.Since(start)
fmt.Println(d) // 5.005354572s

d = time.Until(start)
fmt.Println(d) // -5.005509677s
```

事实上，`Since(t)`等价于`time.Now().Sub(t)`，`Until(t)`等价于`t.Sub(time.Now())`。

通过`ParseDuration`方法可以将一个字符串转化为`Duration`：

```go
d, err := time.ParseDuration("1h2m3s4ms")
if err != nil {
    fmt.Println(err)
} else {
    fmt.Println(d) // 1h2m3.004s
}
```

## Location

`Location`用来表示不同的时区位置。通过`LoadLocation`可以加载内置的时区信息，`FixedZone`可以自定义时区信息。例如：

```go
utc, err := time.LoadLocation("UTC")
local, err := time.LoadLocation("Local")
la, err := time.LoadLocation("America/Los_Angeles")
china := time.FixedZone("china", 8*3600) // +0800, offset in second is 8*3600
```

`LoadLocation`方法中，参数可以是`UTC`，`Local`以及时区数据库中的名字，如果在时区数据库中查找，会按照如下顺序：

- `ZONEINFO`环境变量所指定的zip文件
- Unix系统中已经安装的
- `$GOROOT/lib/time/zoneinfo.zip`

## Time

`Time`表示了纳秒级精度的时间。通过`time.Now()`可以得到当前时间。

```go
d := time.Now()

fmt.Println(d) // 2017-05-13 16:10:20.938354919 +0800 CST

year, month, day := d.Date()
fmt.Println(year, month, day) // 2017 May 13

year, week := d.ISOWeek()
fmt.Println(year, week) // 2017 19

hour, minute, second := d.Clock()
fmt.Println(hour, minute, second) // 16 10 20

fmt.Println(d.Year())       // 2017
fmt.Println(d.Month())      // May
fmt.Println(d.Day())        // 13
fmt.Println(d.Hour())       // 16
fmt.Println(d.Minute())     // 10
fmt.Println(d.Second())     // 20
fmt.Println(d.Nanosecond()) // 938354919

fmt.Println(d.Weekday()) // Saturday
fmt.Println(d.YearDay()) // 133

fmt.Println(d.Unix())     // 1494663020
fmt.Println(d.UnixNano()) // 1494663020938354919
```

还可以通过`Date`方法指定年月日等字段以及时区信息，例如：

```go
la, _ := time.LoadLocation("America/Los_Angeles")
d := time.Date(2006, 1, 2, 15, 4, 5, 0, la)

fmt.Println(d)            // 2006-01-02 15:04:05 -0800 PST
fmt.Println(d.UTC())      // 2006-01-02 23:04:05 +0000 UTC
fmt.Println(d.Local())    // 2006-01-03 07:04:05 +0800 CST
fmt.Println(d.Location()) // America/Los_Angeles
```

### 时间运算

- `Before`，`After`和`Equal`方法用来比较时间先后
- `Add`方法可以用来加一个`Duration`得到一个新的时间
- `Sub`为两个时间相减得到一个`Duration`
- `AddDate`可以加相应数量的年月日得到一个新的时间

```go
d1 := time.Now()
d2 := d1.Add(10 * time.Second)
d3 := d1.Add(-10 * time.Second)
d4 := d2.Add(-20 * time.Second)
d5 := d1.AddDate(1, 2, 3)

fmt.Println(d1.Before(d2)) // true
fmt.Println(d1.After(d3))  // true
fmt.Println(d3.Equal(d4))  // true
fmt.Println(d2.Sub(d1))    // 10s

fmt.Println(d1) // 2017-05-13 22:14:49.170798749 +0800 CST
fmt.Println(d5) // 2018-07-16 22:14:49.170798749 +0800 CST
```

### 格式化

在Go语言中，日期的格式化与其它语言的YYYYMMDD形式差别很大，用的是具体描述形式的形式，参考日期为`Mon Jan 2 15:04:05 MST 2006`。一些日期格式常量如下：

```go
const (
        ANSIC       = "Mon Jan _2 15:04:05 2006"
        UnixDate    = "Mon Jan _2 15:04:05 MST 2006"
        RubyDate    = "Mon Jan 02 15:04:05 -0700 2006"
        RFC822      = "02 Jan 06 15:04 MST"
        RFC822Z     = "02 Jan 06 15:04 -0700" // RFC822 with numeric zone
        RFC850      = "Monday, 02-Jan-06 15:04:05 MST"
        RFC1123     = "Mon, 02 Jan 2006 15:04:05 MST"
        RFC1123Z    = "Mon, 02 Jan 2006 15:04:05 -0700" // RFC1123 with numeric zone
        RFC3339     = "2006-01-02T15:04:05Z07:00"
        RFC3339Nano = "2006-01-02T15:04:05.999999999Z07:00"
        Kitchen     = "3:04PM"
        // Handy time stamps.
        Stamp      = "Jan _2 15:04:05"
        StampMilli = "Jan _2 15:04:05.000"
        StampMicro = "Jan _2 15:04:05.000000"
        StampNano  = "Jan _2 15:04:05.000000000"
)
```

通过`Format`方法可以格式化日期为字符串形式，例如：

```go
d := time.Now()

fmt.Println(d.Format(time.ANSIC))       // Sun May 14 10:31:27 2017
fmt.Println(d.Format(time.UnixDate))    // Sun May 14 10:31:27 CST 2017
fmt.Println(d.Format(time.RubyDate))    // Sun May 14 10:31:27 +0800 2017
fmt.Println(d.Format(time.RFC822))      // 14 May 17 10:31 CST
fmt.Println(d.Format(time.RFC822Z))     // 14 May 17 10:31 +0800
fmt.Println(d.Format(time.RFC850))      // Sunday, 14-May-17 10:31:27 CST
fmt.Println(d.Format(time.RFC1123))     // Sun, 14 May 2017 10:31:27 CST
fmt.Println(d.Format(time.RFC1123Z))    // Sun, 14 May 2017 10:31:27 +0800
fmt.Println(d.Format(time.RFC3339))     // 2017-05-14T10:31:27+08:00
fmt.Println(d.Format(time.RFC3339Nano)) // 2017-05-14T10:31:27.67117435+08:00
fmt.Println(d.Format(time.Kitchen))     // 10:31AM
fmt.Println(d.Format(time.Stamp))       // May 14 10:31:27
fmt.Println(d.Format(time.StampMilli))  // May 14 10:31:27.671
fmt.Println(d.Format(time.StampMicro))  // May 14 10:31:27.671174
fmt.Println(d.Format(time.StampNano))   // May 14 10:31:27.671174350

fmt.Println(d.Format("2006-01-02 15:04:05")) // 2017-05-14 10:31:27
```

与`Format`方法相反，`Parse`方法可以将字符串转换为时间。例如：

```go
s := time.Now().Format(time.ANSIC)
fmt.Println(s) // Sun May 14 10:38:27 2017

d, _ := time.Parse(time.ANSIC, s)
fmt.Println(d) // 2017-05-14 10:38:27 +0000 UTC

d, _ = time.Parse("2006-01-02 15:04:05", "2000-01-01 00:00:00")
fmt.Println(d) // 2000-01-01 00:00:00 +0000 UTC

local, _ := time.LoadLocation("Local")
d, _ = time.ParseInLocation("2006-01-02 15:04:05", "2000-01-01 00:00:00", local)
fmt.Println(d) // 2000-01-01 00:00:00 +0800 CST
```

