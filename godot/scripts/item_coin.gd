extends Area2D  # 만약 CharacterBody2D라면 수정해 주세요!

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	print("🟢 [ItemCoin] 코인이 준비되었습니다! 현재 월드 위치: ", global_position)
	# 마우스 클릭을 감지하려면 이 옵션이 무조건 켜져 있어야 합니다.
	input_pickable = true

# 1. 코인 영역 안에서 마우스 클릭을 감지하는 함수
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			# 마우스 포인터가 코인의 중심에서 얼마나 떨어져서 클릭되었는지 저장 (부드러운 드래그용)
			drag_offset = global_position - get_global_mouse_position()
			print("🎯 [ItemCoin] 클릭 감지! 드래그를 시작합니다. (Offset: ", drag_offset, ")")
			
			# 이 클릭 이벤트를 코인이 먹었다고 엔진에 알려서 다른 노드로 전파되는 것을 막습니다.
			get_viewport().set_input_as_handled()

# 2. 마우스 움직임과 버튼 뗌을 감지하는 글로벌 함수
func _input(event: InputEvent) -> void:
	if not is_dragging:
		return

	# 드래그 도중 마우스 버튼을 뗐을 때
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false
			print("🏁 [ItemCoin] 드래그 종료! 아이템을 최종 배치한 위치: ", global_position)

	# 마우스를 움직이는 "중간 과정" 실시간 처리
	elif event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset
		# 주석을 해제하면 마우스 움직일 때마다 좌표가 실시간으로 찍힙니다 (약간 복잡해질 수 있음)
		# print("🔄 [ItemCoin] 드래그 중... 현재 마우스 좌표: ", global_position)
