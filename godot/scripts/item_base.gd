extends Area2D
class_name ItemBase

@export var item_res: ItemRes
@export var move_cost: float = 15

var is_left_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_drag_position: Vector2 = Vector2.ZERO
var float_tween: Tween
var original_scale: Vector2 = Vector2.ONE
var is_cleared: bool = false # 캐릭터에게 위험 요소인지 판단 

signal pickup

func _ready() -> void:
	original_scale = scale

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if GameState.action_point < move_cost:
			return
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
		
		# 자식 클래스에서 특별한 상호작용(ex: 표지판 부착 등)을 처리했다면 둥둥 뜨지 않음
		if _check_world_interaction():
			return
			
		_on_dropped_in_world()

func _get_hovered_slot_index() -> int:
	var current_scene = get_tree().current_scene
	var containers = current_scene.find_children("SlotContainer", "Control", true, false)
	if containers.size() > 0:
		var slot_container = containers[0]
		var mouse_pos = get_viewport().get_mouse_position()
		for child in slot_container.get_children():
			if child is Control and child.is_visible_in_tree():
				if child.get_global_rect().has_point(mouse_pos):
					return child.get_index()
	return -1

# item_base.gd 안의 함수를 찾아서 아래처럼 print를 추가해 봅니다.

func _pickup_to_specific_slot(s_index: int) -> void:
	# 🌟 [디버깅 코드 추가] 콘솔창에 상황을 출력해 봅니다.
	print("=== 인벤토리 아이템 획득 시도 ===")
	print("1. 내 노드 이름: ", name)
	print("2. 연결된 리소스(tres): ", item_res)
	if item_res:
		print("3. 리소스 안의 아이템 이름: ", item_res.item_name)
		print("4. 리소스 안의 아이콘 이미지: ", item_res.icon)
	print("5. 넣으려는 슬롯 번호: ", s_index)
	print("=================================")

	# 기존 조건문 시작...
	if s_index < inventory_manager.items.size() and inventory_manager.items[s_index] == null:
		inventory_manager.items[s_index] = item_res
		if inventory_manager.ui:
			inventory_manager.ui.queue_redraw()
		pickup.emit()
		queue_free()
	else:
		global_position = start_drag_position
		_on_dropped_in_world()
func _consume_cost() -> void:
	GameState.action_point -= move_cost

# 기본적으로 월드에 떨어지면 경로를 찾아 둥둥 뜹니다.
func _on_dropped_in_world() -> void:
	start_floating()

# 🌟 [오리지널 로직 복구] 가장 가까운 Path2D 선을 찾아 Y축 높이를 맞추는 함수
func start_floating() -> void:
	print("start floating")
	is_cleared = true
	
	if float_tween: float_tween.kill()
	float_tween = create_tween()
	
	# 기본값은 현재 놓은 위치에서 살짝 위
	var target_y: float = global_position.y - 30.0 
	var min_distance: float = INF
	
	# 현재 씬에 존재하는 모든 Path2D 노드들을 검색
	var paths = get_tree().current_scene.find_children("*", "Path2D", true, false)
	for node in paths:
		# 부모 노드가 PathChoice 클래스이거나 curve를 가지고 있는지 검사
		if node.curve:
			var path = node
			var local_pos = path.to_local(global_position)
			var closest_local = path.curve.get_closest_point(local_pos)
			var closest_global = path.global_transform * closest_local
			var dist = global_position.distance_to(closest_global)
			
			# 가장 가까운 경로 노드를 찾으면 해당 경로의 Y값 기준 -30 위치를 타겟으로 설정
			if dist < min_distance:
				min_distance = dist
				target_y = closest_global.y - 30.0
				
	# 찾은 경로의 높이로 부드럽게 이동한 후 위아래 보빙(Bobbing) 애니메이션 시작
	float_tween.tween_property(self, "global_position:y", target_y, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	float_tween.tween_callback(start_bobbing)

func start_bobbing() -> void:
	if float_tween: float_tween.kill()
	float_tween = create_tween().set_loops()
	var current_y = global_position.y
	float_tween.tween_property(self, "global_position:y", current_y - 5.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(self, "global_position:y", current_y + 5.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# 자식들이 덮어쓸 가상 함수
func _check_world_interaction() -> bool:
	return false
