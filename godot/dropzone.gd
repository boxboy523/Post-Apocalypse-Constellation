extends Control

const COIN_SCENE = preload("res://coin.tscn")

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("▶ [드롭 성공] 마우스를 놓았습니다. 데이터: ", data)
	
	var item_index = inventorymanager.items.find(str(data))
	if item_index != -1:
		inventorymanager.items.remove_at(item_index)
		print("🎒 가방 상황: ", inventorymanager.items)
	
	var new_coin = COIN_SCENE.instantiate()
	new_coin.global_position = get_canvas_transform().affine_inverse() * at_position
	get_tree().current_scene.add_child(new_coin)


func _mouse_enter() -> void:
	print("● [감지] 마우스가 투명 도화지(dropzone) 영역으로 들어옴")
