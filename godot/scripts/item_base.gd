extends Area2D
class_name ItemBase

@export var item_res: ItemRes

# 월드 드래그용 변수
var is_left_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
signal pickup

# 1️⃣ 아이템 위에서 발생하는 마우스 이벤트 (클릭 감지)
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:

	# [우클릭] 아이템 획득
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_pickup()

	# [좌클릭] 맵 내에서 드래그 시작
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_left_dragging = true
		# 마우스와 아이템 중심 사이의 거리(오프셋)를 기억해서 자연스럽게 끌리도록 함
		drag_offset = global_position - get_global_mouse_position()

# 2️⃣ 화면 전체에서 발생하는 마우스 이벤트 (클릭 뗌 감지)
func _input(event: InputEvent) -> void:
	# 마우스를 빠르게 움직여서 아이템 밖으로 커서가 벗어나더라도 드롭을 인식해야 하므로 _input 사용
	if is_left_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_left_dragging = false

# 3️⃣ 매 프레임 실행 (드래그 중일 때 위치 이동)
func _process(_delta: float) -> void:
	if is_left_dragging:
		global_position = get_global_mouse_position() + drag_offset

func _pickup() -> void:
	print("📦 [ItemBase] 아이템 획득: ", item_res.name)

	if item_res and inventory_manager.add_item(item_res):
		print("✅ [인벤토리] 아이템이 가방에 추가되었습니다: ", item_res.name)
		pickup.emit()
		_on_pickup_success()
		queue_free()
	else:
		print("가방이 꽉 찼습니다!")

func _on_pickup_success() -> void:
	pass

func on_dropped() -> void:
	pass
