extends Control

const ITEM_COIN_SCENE = preload("res://scenes/item_coin.tscn")

var slot_index: int:
	get: return get_index()

var is_left_dragging: bool = false
var drag_preview: TextureRect = null
var drag_layer: CanvasLayer = null 

func _gui_input(event: InputEvent) -> void:
	# 1. 좌클릭 '누를 때' (드래그 시작)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if slot_index < inventory_manager.items.size() and inventory_manager.items[slot_index] != null:
			var current_item = inventory_manager.items[slot_index]
			is_left_dragging = true
			
			# 기존 UI들에 가려지지 않도록 최상단(100) 캔버스 레이어 생성
			drag_layer = CanvasLayer.new()
			drag_layer.layer = 100
			get_tree().current_scene.add_child(drag_layer)
			
			drag_preview = TextureRect.new()
			drag_preview.texture = current_item.icon
			drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			drag_preview.custom_minimum_size = Vector2(40, 40)
			drag_preview.size = Vector2(40, 40)
			drag_preview.modulate.a = 0.6
			drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE # 프리뷰가 클릭을 방해하지 않게 설정
			
			drag_layer.add_child(drag_preview)
			_update_preview_position()
			
	# 2. 좌클릭 '뗄 때' (드롭)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_left_dragging:
			is_left_dragging = false
			
			if drag_layer:
				drag_layer.queue_free()
				drag_layer = null
				drag_preview = null
			
			var target_slot_index = _get_target_slot_index()
			
			if target_slot_index != -1:
				# [인벤토리 내 이동/스왑]
				if target_slot_index != slot_index:
					var temp = inventory_manager.items[target_slot_index]
					inventory_manager.items[target_slot_index] = inventory_manager.items[slot_index]
					inventory_manager.items[slot_index] = temp
					if inventory_manager.ui:
						inventory_manager.ui.queue_redraw()
			else:
				# [월드에 방출]
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

# 3. 드래그 중일 때 화면 어디서든 마우스 따라가기
func _input(event: InputEvent) -> void:
	if is_left_dragging and event is InputEventMouseMotion:
		_update_preview_position()

func _update_preview_position() -> void:
	if drag_preview:
		# CanvasLayer 위에 있으므로 viewport 좌표를 그대로 사용하면 완벽히 일치합니다.
		var mouse_pos = get_viewport().get_mouse_position()
		drag_preview.position = mouse_pos - (drag_preview.size / 2.0)

func _get_target_slot_index() -> int:
	var container = get_parent() 
	if not container: return -1
	
	# 부모 컨테이너 좌표계에 의존하지 않고, 화면 절대 좌표(global_rect)로 충돌 검사
	var mouse_pos = get_viewport().get_mouse_position()
	for child in container.get_children():
		if child is Control and child.is_visible_in_tree():
			if child.get_global_rect().has_point(mouse_pos):
				return child.get_index()
	return -1
