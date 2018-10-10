# container/heap

## Interface

关于堆的介绍参看[Heap](https://en.wikipedia.org/wiki/Heap_(data_structure))。

在Go中实现的是一个最小堆，即每个节点的值总是以该节点为根节点的子树的最小值。同时应当注意到，对于任意一个节点，假设其下表为`i`，则其父节点下标为`(i - 1) / 2`，其左子节点下标为`2 * i + 1`，其右子节点下标为`2 * i + 2`。

在heap包中，定义了一个`heap.Interface`接口，只要实现该接口的数据结构，都可以作为一个堆来使用。

```go
type Interface interface {
    sort.Interface
    Push(x interface{}) // add x as element Len()
    Pop() interface{}   // remove and return element Len() - 1.
}
```

## down 和 up

heap操作中最重要的两个方法是`down`和`up`。

`down`让一个节点下沉：

```go
func down(h Interface, i0, n int) bool {
    i := i0
    for {
        // j1为左子节点下标
        j1 := 2*i + 1
        if j1 >= n || j1 < 0 { // j1 < 0 after int overflow
            break
        }
        j := j1 // left child
        // j2为右子节点下标，j为最小的子节点的下标
        if j2 := j1 + 1; j2 < n && !h.Less(j1, j2) {
            j = j2 // = 2*i + 2  // right child
        }
        // 如果最小的子节点不小于父节点，则已经满足最小堆条件，退出
        if !h.Less(j, i) {
            break
        }
        // 如果最小的子节点小于父节点，则交换这两个节点
        h.Swap(i, j)
        // 让父节点继续下沉
        i = j
    }
    return i > i0
}
```

`up`让一个节点上升：

```go
func up(h Interface, j int) {
    for {
        // i为父节点下标
        i := (j - 1) / 2 // parent
        // 如果该节点不小于父节点，则满足最小堆条件，退出
        if i == j || !h.Less(j, i) {
            break
        }
        // 如果该节点小于父节点，则交换这两个节点
        h.Swap(i, j)
        // 让该节点继续上升
        j = i
    }
}
```

## Init

```go
func Init(h Interface) {
    n := h.Len()
    // 最后一个节点下表为n-1，因此其父节点为(n-1-1)/2，即n/2-1
    for i := n/2 - 1; i >= 0; i-- {
        down(h, i, n)
    }
}
```

## Push

```go
func Push(h Interface, x interface{}) {
    h.Push(x)
    up(h, h.Len()-1)
}
```

`Push`的时候，先把新元素放置在结尾，然后让其上升。

## Pop

```go
func Pop(h Interface) interface{} {
    n := h.Len() - 1
    h.Swap(0, n)
    down(h, 0, n)
    return h.Pop()
}
```

`Pop`的时候，先把根节点和最后一个节点交换位置，然后让新的根节点下降。注意这里`down`的第三个参数是`n`的值为`h.Len() - 1`，因此新的根节点下降的过程中，原先的根节点位于最后的位置，不受影响。

## Remove

```go
func Remove(h Interface, i int) interface{} {
    n := h.Len() - 1
    if n != i {
        h.Swap(i, n)
        down(h, i, n)
        up(h, i)
    }
    return h.Pop()
}
```

`Remove`操作与`Pop`非常类似，先将需要移除的节点和最后一个节点交换位置，然后同时进行`down`和`up`操作。

## Fix

```go
func Fix(h Interface, i int) {
    if !down(h, i, h.Len()) {
        up(h, i)
    }
}
```

当某个节点的值改变后，通过`Fix`操作来调整堆的结构。该操作实际上也是同时进行了`down`和`up`操作。

与先移除旧节点再添加新节点相比，`Fix`操作的复杂度要低一些。