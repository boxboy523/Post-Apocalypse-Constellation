# inventory_slot.gd
extends Control

const ITEM_COIN_SCENE = preload("res://scenes/item_coin.tscn")

# GridContainer 안에서 자신이 몇 번째 자식인지 자동 인덱스 사용
var slot_index: int:
	get: return get_index()

var is_right_dragging: bool = false
var drag_preview: TextureRect = null

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		
		if slot_index < inventory_manager.items.size() and inventory_manager.items[slot_index] != null:
			var current_item = inventory_manager.items[slot_index]
			
			if current_item.name == "Coin":
				is_right_dragging = true
				print("🔄 [슬롯 %d] 우클릭 드래그 시작!" % slot_index)
				
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

func _input(event: InputEvent) -> void:
	if not is_right_dragging:
		return
		
	if event is InputEventMouseMotion:
		_update_preview_position()
		
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		is_right_dragging = false
		print("🏁 [슬롯 %d] 드롭!" % slot_index)
		
		if drag_preview:
			drag_preview.queue_free()
			drag_preview = null
		
		# 원래 아이템 데이터 백업
		var dropped_item_data = inventory_manager.items[slot_index]
		
		# 데이터 삭제 및 UI 갱신
		inventory_manager.items[slot_index] = null
		if inventory_manager.ui:
			inventory_manager.ui.queue_redraw()
			
		# 월드에 아이템 이미지 소환
		var new_coin = ITEM_COIN_SCENE.instantiate()
		
		new_coin.item_res = dropped_item_data
		
		new_coin.global_position = get_tree().current_scene.get_global_mouse_position()
		get_tree().current_scene.add_child(new_coin)
		
		if new_coin.has_method("on_dropped"):
			new_coin.on_dropped()
			
		get_viewport().set_input_as_handled()

func _update_preview_position() -> void:
	if drag_preview and drag_preview.get_parent():
		var mouse_pos = drag_preview.get_parent().get_local_mouse_position()
		drag_preview.position = mouse_pos - (drag_preview.size / 2)
