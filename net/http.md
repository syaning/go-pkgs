# http

## 辅助方法

### CanonicalHeaderKey

与`textproto.CanonicalMIMEHeaderKey`效果相同。

## Handler 和 HandlerFunc

`Handler`是一个`interface`：

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

`HandlerFunc`是一类函数，它的参数列表与`Handler`的`ServeHTTP`方法的参数列表相同：

```go
type HandlerFunc func(ResponseWriter, *Request)
```

并且它实现了`ServeHTTP`方法：

```go
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
    f(w, r)
}
```

因此，`HandlerFunc`的主要作用就是将一个普通函数包装成一个`Handler`：

```go
var f = func(w http.ResponseWriter, r *http.Request) {}
var g interface{} = http.HandlerFunc(f)
_, ok := g.(http.Handler)
fmt.Println(ok) // true
```

## Cookie 和 CookieJar

```go
// This implementation is done according to RFC 6265:
//
//    http://tools.ietf.org/html/rfc6265

// A Cookie represents an HTTP cookie as sent in the Set-Cookie header of an
// HTTP response or the Cookie header of an HTTP request.
type Cookie struct {
    Name       string
    Value      string
    Path       string
    Domain     string
    Expires    time.Time
    RawExpires string

    // MaxAge=0 means no 'Max-Age' attribute specified.
    // MaxAge<0 means delete cookie now, equivalently 'Max-Age: 0'
    // MaxAge>0 means Max-Age attribute present and given in seconds
    MaxAge   int
    Secure   bool
    HttpOnly bool
    Raw      string
    Unparsed []string // Raw text of unparsed attribute-value pairs
}
```

例如：

```go
c := http.Cookie{
    Name:   "token",
    Value:  "abcd1234",
    Path:   "/",
    MaxAge: 3600,
}
fmt.Println(c.String()) // "token=abcd1234; Path=/; Max-Age=3600"
```

`CookieJar`是一个接口：

```go
// A CookieJar manages storage and use of cookies in HTTP requests.
//
// Implementations of CookieJar must be safe for concurrent use by multiple
// goroutines.
//
// The net/http/cookiejar package provides a CookieJar implementation.
type CookieJar interface {
    // SetCookies handles the receipt of the cookies in a reply for the
    // given URL.  It may or may not choose to save the cookies, depending
    // on the jar's policy and implementation.
    SetCookies(u *url.URL, cookies []*Cookie)

    // Cookies returns the cookies to send in a request for the given URL.
    // It is up to the implementation to honor the standard cookie use
    // restrictions such as in RFC 6265.
    Cookies(u *url.URL) []*Cookie
}
```

`net/http/cookiejar`提供了一个具体的实现。

## Header

与`textproto.MIMEHeader`类似，本质上也是一个`map[string][]string`。同样拥有`Add`，`Set`，`Get`，`Del`方法，此外还有`Write`和`WriteSubset`方法。

```go
h := http.Header{}
h.Set("Content-Type", "application/json")
h.Add("Accept-Encoding", "gzip")
h.Add("Accept-Encoding", "deflate")
h.Set("Cache-Control", "no-cache")

h.Write(os.Stdout)
// Accept-Encoding: gzip
// Accept-Encoding: deflate
// Cache-Control: no-cache
// Content-Type: application/json

h.WriteSubset(os.Stdout, map[string]bool{
    "Accept-Encoding": true,
})
// Cache-Control: no-cache
// Content-Type: application/json
```

## Request

`Request`是对HTTP的封装，包括作为服务器接收到的请求以及作为客户端发出的请求。相关的字段可以参看[http.Request](https://golang.org/pkg/net/http/#Request)。

作为客户端发出的请求时，有以下方法：

- AddCookie(c *Cookie)
- SetBasicAuth(username, password string)

作为服务器接收的请求时，有以下方法：

- BasicAuth() (username, password string, ok bool)
- Cookie(name string) (*Cookie, error)
- Cookies() []*Cookie
- FormFile(key string) (multipart.File, *multipart.FileHeader, error)
- FormValue(key string) string
- PostFormValue(key string) string
- Referer() string
- UserAgent() string

为了获取表单的参数值，需要先调用`ParseForm`或者`ParseMultipartForm`，例如：

```go
http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    r.ParseForm()

    fmt.Println("UserAgent:", r.UserAgent())
    fmt.Println(r.Form)
    fmt.Println(r.PostForm)

    w.Write([]byte("hello world"))
})
http.ListenAndServe(":8080", nil)
```

执行：

```sh
curl -X POST -d "hello=world" "localhost:8080/?a=b&c=d"
```

输出为：

```
UserAgent: curl/7.51.0
map[hello:[world] a:[b] c:[d]]
map[hello:[world]]
```

## Response

当作为客户端发请求时，服务器的返回就是一个`Request`。具体字段可以参看[http.Response](https://golang.org/pkg/net/http/#Response)。

一下几个HTTP方法都可以得到一个`Response`：

- Get(url string) (resp *Response, err error)
- Head(url string) (resp *Response, err error)
- Post(url string, contentType string, body io.Reader) (resp *Response, err error)
- PostForm(url string, data url.Values) (resp *Response, err error)

例如：

```go
resp, err := http.Get("https://httpbin.org/user-agent")
if err != nil {
    fmt.Println(err)
    return
}
defer resp.Body.Close()

body, err := ioutil.ReadAll(resp.Body)
fmt.Println(string(body))
// { "user-agent": "Go-http-client/1.1" }
```

## Client

`Client`作为客户端发请求。有如下方法：

- func (c *Client) Do(req *Request) (*Response, error)
- func (c *Client) Get(url string) (resp *Response, err error)
- func (c *Client) Head(url string) (resp *Response, err error)
- func (c *Client) Post(url string, contentType string, body io.Reader) (resp *Response, err error)
- func (c *Client) PostForm(url string, data url.Values) (resp *Response, err error)

事实上，`Get`，`Head`，`Post`，`PostForm`都是构建好`Request`对象后，调用`Do`方法。

有一个全局的`DefaultClient`对象，全局的`Get`，`Head`，`Post`，`PostForm`其实是调用了`DefaultClient`的相应方法。

如果只是发送简单的请求，直接用`http.Get`等这些方法就可以了，如果需要定制header等行为，则需要显式使用`client.Do(req)`。
