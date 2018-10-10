# container/list

list定义了一个双向链表。

## Element

list的元素定义如下：

```go
type Element struct {
    // Next and previous pointers in the doubly-linked list of elements.
    // The front of the list has prev = nil, and the back has next = nil.
    next, prev *Element

    // The list to which this element belongs.
    list *List

    // The contents of this list element.
    Value interface{}
}
```

Element定义了`Next()`和`Prev()`方法，定义如下：

```go
// Next returns the next list element or nil.
func (e *Element) Next() *Element {
    if p := e.next; e.list != nil && p != &e.list.root {
        return p
    }
    return nil
}

// Prev returns the previous list element or nil.
func (e *Element) Prev() *Element {
    if p := e.prev; e.list != nil && p != &e.list.root {
        return p
    }
    return nil
}
```

总的来说，这两个方法的执行逻辑是：

- 如果该元素在某一个链表上，且其前一个（后一个）元素不是链表的根元素，则返回其前一个（后一个）元素
- 其它情况下，即如果该元素不属于任何链表，或者其前一个（后一个）元素为链表的根元素，则返回`nil`（即：链表的根元素只起到一个占位作用，而并不会存储数据值）

## List

通过`New()`方法可以创建一个新的链表：

```go
// List represents a doubly linked list.
// The zero value for List is an empty list ready to use.
type List struct {
    root Element // sentinel list element, only &root, root.prev, and root.next are used
    len  int     // current list length excluding (this) sentinel element
}

// Init initializes or clears list l.
func (l *List) Init() *List {
    l.root.next = &l.root
    l.root.prev = &l.root
    l.len = 0
    return l
}

// New returns an initialized list.
func New() *List { return new(List).Init() }
```

可以看到，`New()`实际上调用了`Init()`方法，主要作用就是初始化一个链表的根元素。

事实上，List是一个首尾相连的环状结构，只不过由于根元素只是起到了占位作用，对外是不可见的，因此对于用户操作来说，看到的是一个链状结构。

其相关操作以及源码都比较简单，不做赘述。下面是一个例子：

```go
package main

import (
    "container/list"
    "fmt"
)

func main() {
    l := list.New()

    l.PushBack("a")
    printList(l) // a

    l.PushBack("b")
    printList(l) // a b

    l.PushFront("c")
    printList(l) // c a b

    fmt.Println(l.Front().Value) // c
    fmt.Println(l.Back().Value)  // b
    fmt.Println(l.Len())         // 3

    l.MoveToBack(l.Front())
    printList(l) // a b c

    l.MoveToFront(l.Back())
    printList(l) // c a b

    l.Remove(l.Back())
    printList(l) // c a
}

func printList(l *list.List) {
    for e := l.Front(); e != nil; e = e.Next() {
        fmt.Print(e.Value, " ")
    }
    fmt.Println()
}
```
