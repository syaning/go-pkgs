# heap

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
