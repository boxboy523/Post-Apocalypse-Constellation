extends Area2D

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	input_pickable = true
	print("🟢 [ItemCoin] 월드 코인이 준비되었습니다. 위치: ", global_position)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		# [기존] 좌클릭 드래그 기능
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_offset = global_position - get_global_mouse_position()
				print("🎯 [월드 코인] 좌클릭 드래그 시작!")
				get_viewport().set_input_as_handled()
		
		# 🔥 [신규] 우클릭했을 때 인벤토리로 자동 습득
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				print("🎒 [월드 코인 우클릭] 코인을 인벤토리에 추가합니다.")
				inventory_manager.items.append("item_coin")
				print("💾 현재 가방 상황: ", inventory_manager.items)
				
				# 월드에서 코인 노드 삭제
				queue_free()
				get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if not is_dragging:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false
			print("🏁 [월드 코인] 좌클릭 드래그 종료! 배치 위치: ", global_position)

	elif event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset
