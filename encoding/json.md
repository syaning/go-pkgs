# json

## Marshal

```go
package main

import (
    "encoding/json"
    "fmt"
)

func main() {
    data := map[string]interface{}{
        "name": "bob",
        "age":  20,
        "tags": []string{"sport", "music"},
    }
    b, _ := json.Marshal(data)
    fmt.Println(string(b))
}

// {"age":20,"name":"bob","tags":["sport","music"]}
```

## MarshalIndent

```go
package main

import (
    "encoding/json"
    "fmt"
)

func main() {
    data := map[string]interface{}{
        "name": "bob",
        "age":  20,
        "tags": []string{"sport", "music"},
    }
    b, _ := json.MarshalIndent(data, "", "  ")
    fmt.Println(string(b))
}
```

输出：

```
{
    "age": 20,
    "name": "bob",
    "tags": [
        "sport",
        "music"
    ]
}
```

## Unmarshal

```go
package main

import (
    "encoding/json"
    "fmt"
)

type Animal struct {
    Name  string
    Order string
}

func main() {
    var jsonBlob = []byte(`[
        {"Name": "Platypus", "Order": "Monotremata"},
        {"Name": "Quoll",    "Order": "Dasyuromorphia"}
    ]`)
    var animals []Animal
    err := json.Unmarshal(jsonBlob, &animals)
    if err != nil {
        fmt.Println("error:", err)
    }
    fmt.Printf("%+v", animals)
}

// [{Name:Platypus Order:Monotremata} {Name:Quoll Order:Dasyuromorphia}]
```

## 使用 tags

```go
package main

import (
    "encoding/json"
    "fmt"
)

type User struct {
    Name string   `json:"name"`
    Age  int      `json:"age,omitempty"`
    Tags []string `json:"tags"`
}

func main() {
    user := &User{
        Name: "bob",
        Tags: []string{"sport", "music"},
    }
    b, _ := json.Marshal(user)
    fmt.Println(string(b))
    // {"name":"bob","tags":["sport","music"]}

    newUser := User{}
    json.Unmarshal(b, &newUser)
    fmt.Println(newUser)
    // {bob 0 [sport music]}
}
```
