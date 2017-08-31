# json

## Marshal

```go
data := map[string]interface{}{
    "name": "bob",
    "age":  20,
    "tags": []string{"sport", "music"},
}
b, _ := json.Marshal(data)
fmt.Println(string(b))

// {"age":20,"name":"bob","tags":["sport","music"]}
```

## MarshalIndent

```go
data := map[string]interface{}{
    "name": "bob",
    "age":  20,
    "tags": []string{"sport", "music"},
}
b, _ := json.MarshalIndent(data, "", "  ")
fmt.Println(string(b))
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
var jsonBlob = []byte(`[
    {"Name": "Platypus", "Order": "Monotremata"},
    {"Name": "Quoll",    "Order": "Dasyuromorphia"}
]`)
type Animal struct {
    Name  string
    Order string
}
var animals []Animal
err := json.Unmarshal(jsonBlob, &animals)
if err != nil {
    fmt.Println("error:", err)
}
fmt.Printf("%+v", animals)

// [{Name:Platypus Order:Monotremata} {Name:Quoll Order:Dasyuromorphia}]
```
