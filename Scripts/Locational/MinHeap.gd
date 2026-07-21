class_name MinHeap
extends RefCounted
## Binary min-heap of (priority, value) pairs. Uses lazy deletion -- when a
## node's distance gets relaxed, we just push it again instead of doing a
## proper decrease-key -- and skip stale entries on pop. Simpler than an
## indexed heap and plenty fast at this graph size.

var heap: Array = [] # entries: [priority, value]

func isEmpty() -> bool:
	return heap.is_empty()

func push(priority: float, value) -> void:
	heap.append([priority, value])
	siftUp(heap.size() - 1)

func pop():
	var top = heap[0][1]
	var last = heap.pop_back()
	if !heap.is_empty():
		heap[0] = last
		siftDown(0)
	return top

func siftUp(i: int) -> void:
	while i > 0:
		var parent: int = (i - 1) / 2
		if heap[i][0] < heap[parent][0]:
			var tmp = heap[i]; heap[i] = heap[parent]; heap[parent] = tmp
			i = parent
		else:
			break

func siftDown(i: int) -> void:
	var size: int = heap.size()
	while true:
		var left: int = i * 2 + 1
		var right: int = i * 2 + 2
		var smallest: int = i
		if left < size and heap[left][0] < heap[smallest][0]:
			smallest = left
		if right < size and heap[right][0] < heap[smallest][0]:
			smallest = right
		if smallest == i:
			break
		var tmp = heap[i]; heap[i] = heap[smallest]; heap[smallest] = tmp
		i = smallest
