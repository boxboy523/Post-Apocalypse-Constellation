extends Control

const ITEM_COIN_SCENE = preload("res://scenes/item_coin.tscn") # 주의: 나중에 여러 아이템을 버리려면 동적으로 씬을 불러오게 수정해야 합니다!

var slot_index: int:
	get: return get_index()

var is_right_dragging: bool = false
var drag_preview: TextureRect = null

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		
		if slot_index < inventory_manager.items.size() and inventory_manager.items[slot_index] != null:
			var current_item = inventory_manager.items[slot_index]
			
			# 아이템 이름 검사("Coin") 조건문을 삭제하여 모든 아이템에 적용되도록 수정
			is_right_dragging = true
			
			# 프리뷰 생성
			drag_preview = TextureRect.new()
			drag_preview.texture = current_item.icon
			drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			drag_preview.size = Vector2(40, 40)
			drag_preview.custom_minimum_size = Vector2(40, 40)
			drag_preview.modulate.a = 0.6
			drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			get_tree().current_scene.add_child(drag_preview)
			_update_preview_position()
			get_viewport().set_input_as_handled()
	
	elif is_right_dragging:
		if event is InputEventMouseMotion:
			_update_preview_position()
			get_viewport().set_input_as_handled()
			
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			is_right_dragging = false
			
			if drag_preview:
				drag_preview.queue_free()
				drag_preview = null
			
			# 마우스를 놓은 곳이 어느 슬롯인지 확인
			var target_slot_index = _get_target_slot_index()
			
			if target_slot_index != -1:
				# 1️⃣ 인벤토리 내 다른 슬롯에 드롭했을 때 -> 스왑(Swap)
				if target_slot_index != slot_index:
					var temp = inventory_manager.items[target_slot_index]
					inventory_manager.items[target_slot_index] = inventory_manager.items[slot_index]
					inventory_manager.items[slot_index] = temp
					
					if inventory_manager.ui:
						inventory_manager.ui.queue_redraw()
			else:
				# 2️⃣ 인벤토리 바깥(배경)에 드롭했을 때 -> 월드에 버리기(Drop)
				var dropped_item_data = inventory_manager.items[slot_index]
				inventory_manager.items[slot_index] = null
				
				if inventory_manager.ui:
					inventory_manager.ui.queue_redraw()
					
				var new_item = ITEM_COIN_SCENE.instantiate()
				new_item.item_res = dropped_item_data
				new_item.global_position = get_tree().current_scene.get_global_mouse_position()
				get_tree().current_scene.add_child(new_item)
				
				if new_item.has_method("on_dropped"):
					new_item.on_dropped()
					
			get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	# 마우스 이벤트가 아니면 즉시 반환 (키보드/기타 입력 통과)
	if not (event is InputEventMouseButton or event is InputEventMouseMotion):
		return
	
	if not is_right_dragging:
		return
		
	if event is InputEventMouseMotion:
		_update_preview_position()
		get_viewport().set_input_as_handled()

func _update_preview_position() -> void:
	if drag_preview and drag_preview.get_parent():
		var mouse_pos = drag_preview.get_parent().get_local_mouse_position()
		drag_preview.position = mouse_pos - (drag_preview.size / 2)

# 현재 마우스 위치가 몇 번째 슬롯 위인지 찾아내는 함수
func _get_target_slot_index() -> int:
	var container = get_parent() # 현재 노드(Slot)의 부모는 SlotContainer입니다.
	if not container:
		return -1
		
	var mouse_pos = container.get_local_mouse_position()
	
	for child in container.get_children():
		if child is Control:
			var rect = Rect2(child.position, child.size)
			if rect.has_point(mouse_pos):
				return child.get_index()
	return -1
