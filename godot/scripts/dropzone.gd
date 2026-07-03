extends Control

const ITEM_COIN_SCENE = preload("res://scenes/item_coin.tscn")

func _ready() -> void:
	# [수정] 게임이 시작되면 평소에는 투명 유령 상태로 만들어 바닥 클릭을 허용합니다.
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _notification(what: int) -> void:
	# [추가] 드래그가 끝나면 (성공하든 사용자가 취소하든) 다시 유령 상태로 돌아갑니다.
	if what == NOTIFICATION_DRAG_END:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("▶ [드롭 성공] 가방에서 꺼낸 데이터: ", data)
	
	var item_index = inventory_manager.items.find(str(data))
	if item_index != -1:
		inventory_manager.items.remove_at(item_index)
		print("🎒 가방 상황: ", inventory_manager.items)
	
	var new_item = ITEM_COIN_SCENE.instantiate()
	new_item.global_position = get_canvas_transform().affine_inverse() * at_position
	get_tree().current_scene.add_child(new_item)
