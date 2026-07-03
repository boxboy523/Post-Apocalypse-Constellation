extends Node

var items: Array[String] = []

func add_item(item_name: String) -> void:
	items.append(item_name)
	print("🎒 가방 상황: ", items)
