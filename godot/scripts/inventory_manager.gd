extends Node

@export var width: int = 8
@export var height: int = 1
var items: Array[ItemRes] = []
var ui: Control

func _ready() -> void:
	items.resize(width * height)

func add_item_pos(item: ItemRes, x: int, y: int) -> void:
	items[y * width + x] = item
	ui.queue_redraw()

func add_item(item: ItemRes) -> bool:
	for i in range(items.size()):
		if items[i] == null:
			print("📦 [InventoryManager] 아이템 추가: ", item.name, " 인덱스: ", i)
			items[i] = item
			ui.queue_redraw()
			return true
	return false
