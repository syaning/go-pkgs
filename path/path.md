# path

## Base

该方法返回一个路径的最后一部分，例如：

```go
fmt.Println(path.Base(""))       // .
fmt.Println(path.Base("/"))      // /
fmt.Println(path.Base("a/b/c"))  // c
fmt.Println(path.Base("a/b/c/")) // c
```

源码如下：

```go
func Base(path string) string {
    if path == "" {
        return "."
    }
    // Strip trailing slashes.
    for len(path) > 0 && path[len(path)-1] == '/' {
        path = path[0 : len(path)-1]
    }
    // Find the last element
    if i := strings.LastIndex(path, "/"); i >= 0 {
        path = path[i+1:]
    }
    // If empty now, it had only slashes.
    if path == "" {
        return "/"
    }
    return path
}
```

总的来说，遵循如下规则：

- 如果参数是空字符处串，返回`.`
- 如果参数是`/`，返回`/`
- 其它情况，去掉末尾的`/`，然后返回最后一个`/`后面的部分

## Clean

该方法返回一个路径的简洁形式，即会将`.`，`..`以及多余的`/`进行解析。例如：

```go
fmt.Println(path.Clean("/a/b//c/../d/")) // /a/b/d
fmt.Println(path.Clean("../a/b//./c"))   // ../a/b/c
```

## IsABbs

判断是否为绝对路径：

```go
func IsAbs(path string) bool {
    return len(path) > 0 && path[0] == '/'
}
```

例如：

```go
fmt.Println(path.IsAbs("/a/b/c")) // true
fmt.Println(path.IsAbs("a/b/c"))  // false
```

## Join

该方法会将多个片段连起来，然后使用`Clean`操作：

```go
func Join(elem ...string) string {
    for i, e := range elem {
        if e != "" {
            return Clean(strings.Join(elem[i:], "/"))
        }
    }
    return ""
}
```

例如：

```go
fmt.Println(path.Join("a", "b", "c"))          // a/b/c
fmt.Println(path.Join("a", "/b", "../c", "d")) // a/c/d
```

## Split

该方法根据最后一个`/`将路径分为两部分:

```go
func Split(path string) (dir, file string) {
    i := strings.LastIndex(path, "/")
    return path[:i+1], path[i+1:]
}
```

例如：

```go
fmt.Println(path.Split("a/b/c"))  // "a/b/", "c"
fmt.Println(path.Split("a/b/c/")) // "a/b/c/", ""
fmt.Println(path.Split(""))       // "", ""
fmt.Println(path.Split("/"))      // "/", ""
fmt.Println(path.Split("a"))      // "", "a"
```

## Dir

该方法返回一个路径的目录部分，实际上就是`Split`操作返回值的第一部分：

```go
func Dir(path string) string {
    dir, _ := Split(path)
    return Clean(dir)
}
```

## Ext

该方法返回路径所表示文件的扩展名，例如：

```go
fmt.Println(path.Ext("a/b/c"))     // ""
fmt.Println(path.Ext("a/b/c.txt")) // .txt
```

## Match

该方法用于路径的模式匹配，例如：

```go
fmt.Println(path.Match("test/*", "test/ab"))  // true <nil>
```
