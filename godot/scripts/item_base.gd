extends Area2D
class_name ItemBase

@export var item_res: ItemRes
@export var move_cost: int = 10 

var is_left_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_drag_position: Vector2 = Vector2.ZERO
var float_tween: Tween
var original_scale: Vector2 = Vector2.ONE 

signal pickup

func _ready() -> void:
	original_scale = scale

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_left_dragging = true
		start_drag_position = global_position 
		drag_offset = global_position - get_global_mouse_position()
		if float_tween:
			float_tween.kill()

func _input(event: InputEvent) -> void:
	if is_left_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_left_dragging = false
		_handle_drop()

func _process(_delta: float) -> void:
	if is_left_dragging:
		global_position = get_global_mouse_position() + drag_offset

func _handle_drop() -> void:
	var target_slot_index = _get_hovered_slot_index()
	
	if target_slot_index != -1:
		_pickup_to_specific_slot(target_slot_index)
	else:
		if global_position.distance_to(start_drag_position) > 5.0:
			_consume_cost() 
		
		# 🌟 [신규 추가] 자식 클래스에서 덮어쓸 수 있는 월드 상호작용 체크 함수
		if _check_world_interaction():
			return # 상호작용(예: 부착, 몹 킬)에 성공했으면 여기서 종료!
			
		_on_dropped_in_world() # 아무런 상호작용이 없었으면 기본 동작(둥둥 뜨기) 실행

# 🌟 자식 클래스들이 덮어쓸 빈 함수 (부모에서는 false만 반환)
func _check_world_interaction() -> bool:
	return false

# 🌟 [핵심] 씬 트리에서 SlotContainer를 찾아 화면 절대 좌표로 비교
func _get_hovered_slot_index() -> int:
	var current_scene = get_tree().current_scene
	# 이름이 "SlotContainer"인 노드를 트리 전체에서 찾습니다.
	var containers = current_scene.find_children("SlotContainer", "Control", true, false)
	
	if containers.size() > 0:
		var slot_container = containers[0]
		var mouse_pos = get_viewport().get_mouse_position()
		
		# 찾은 컨테이너 안의 자식(슬롯)들을 돌며 마우스가 그 위에 있는지 확인
		for child in slot_container.get_children():
			if child is Control and child.is_visible_in_tree():
				if child.get_global_rect().has_point(mouse_pos):
					return child.get_index() # 일치하는 슬롯의 번호 반환
	return -1

func _pickup_to_specific_slot(s_index: int) -> void:
	if s_index < inventory_manager.items.size() and inventory_manager.items[s_index] == null:
		inventory_manager.items[s_index] = item_res
		
		if inventory_manager.ui:
			inventory_manager.ui.queue_redraw()
			
		print("✅ [인벤토리] " + str(s_index) + "번 슬롯에 획득 성공!")
		pickup.emit()
		queue_free()
	else:
		print("❌ 해당 슬롯이 꽉 찼습니다! 제자리로 복구.")
		global_position = start_drag_position
		_on_dropped_in_world()

func _consume_cost() -> void: pass

func _on_dropped_in_world() -> void:
	start_floating()

# --- 둥둥 트윈 함수 (유지) ---
func start_floating() -> void:
	if float_tween: float_tween.kill()
	float_tween = create_tween()
	var target_y: float = global_position.y - 30.0 
	float_tween.tween_property(self, "global_position:y", target_y, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	float_tween.tween_callback(start_bobbing)

func start_bobbing() -> void:
	if float_tween: float_tween.kill()
	float_tween = create_tween().set_loops()
	var current_y = global_position.y
	float_tween.tween_property(self, "global_position:y", current_y - 5.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(self, "global_position:y", current_y + 5.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
