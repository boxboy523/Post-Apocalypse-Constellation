extends Node

# 인벤토리 아이템을 담을 배열
var items: Array[String] = []

# 아이템 획득 함수
func add_item(item_name: String) -> void:
	items.append(item_name)
	print("🎒 가방 상황: ", items)
