# ring

ring是一个首尾相连的list。其中每一个元素的定义如下：

```go
type Ring struct {
    next, prev *Ring
    Value      interface{} // for use by client; untouched by this library
}
```

通过`New`方法可以创建一个特定大小的ring，例如：

```go
r := ring.New(5)
```

## Next 和 Prev

`Next`和`Prev`操作比较简单，不做赘述。

## Len

通过遍历整个ring来统计元素的个数。

## Move

`Move`操作用来获取某个元素之前或者之后的某个元素。

```go
func (r *Ring) Move(n int) *Ring {
    if r.next == nil {
        return r.init()
    }
    switch {
    // 向前找
    case n < 0:
        for ; n < 0; n++ {
            r = r.prev
        }
    // 向后找
    case n > 0:
        for ; n > 0; n-- {
            r = r.next
        }
    }
    return r
}
```

## Link 和 Unlink

`Link`操作可以将两个ring连接起来，比较简单，不做赘述。

`Unlink`可以移除某个元素后面的若干个元素：

```go
func (r *Ring) Unlink(n int) *Ring {
    if n <= 0 {
        return nil
    }
    return r.Link(r.Move(n + 1))
}
```

`Unlink`操作实际上是将起始点与移除后的下一个点进行了`Link`操作，这样中间需要被移除的点就不再出现在该ring中了。
