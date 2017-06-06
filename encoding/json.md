# json

## Marshal

```js
data := map[string]interface{}{
    "name": "bob",
    "age":  20,
    "tags": []string{"sport", "music"},
}
b, _ := json.Marshal(data)
fmt.Println(string(b))

// {"age":20,"name":"bob","tags":["sport","music"]}
```