# net/url

## Userinfo

是对URL中用户名和密码的封装。通过如下两个方法可以创建Userinfo：

- User(username string) *Userinfo
- UserPassword(username, password string) *Userinfo

例如：

```go
u := url.UserPassword("admin", "123456")
fmt.Println(u.Username()) // admin
fmt.Println(u.Password()) // 123456 true
fmt.Println(u)            // admin:123456
```

## Values

用来表示请求参数（query param以及表单）。本质上是`map[string][]string`，与`http.Header`类似，不同是它的key是大小写区分的。同样提供了`Add`，`Del`，`Get`，`Set`方法。另外还有`Encode`方法，返回编码后的字符串。例如：

```go
v := url.Values{}
v.Set("name", "Ava")
v.Add("friend", "Jess")
v.Add("friend", "Sarah")
v.Add("friend", "Zoe")
fmt.Println(v.Encode())
// friend=Jess&friend=Sarah&friend=Zoe&name=Ava
```

