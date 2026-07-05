extends ItemBase 
# (주의: 만약 에디터가 ItemBase를 못 찾는다면 extends "res://scripts/item_base.gd" 처럼 경로로 적어주세요)

@export_enum("up", "down", "middle") var sign_direction: String = "up"
var is_attached: bool = false

func _ready() -> void:
	# ItemBase에 있는 _ready()를 먼저 실행해서 초기 설정을 해줍니다.
	super._ready()

# 마우스로 표지판을 클릭(드래그 시작)할 때 부착 상태를 해제합니다.
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	# ItemBase의 드래그 로직을 먼저 실행합니다.
	super._input_event(viewport, event, shape_idx) 
	
	# 만약 마우스 왼쪽 버튼을 눌러서 잡았다면?
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_attached:
			is_attached = false
			print("표지판을 봉에서 떼어냈습니다!")
			# 필요하다면 여기서 봉의 가중치를 기본값으로 되돌리는 로직을 추가할 수 있습니다.

# 🌟 핵심: 마우스를 놨을 때(Drop) ItemBase가 이 함수를 호출합니다!
func _check_world_interaction() -> bool:
	if is_attached:
		return true
		
	# 마우스를 놓은 위치에 다른 Area2D가 겹쳐있는지 확인합니다.
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		# 겹친 것 중에 표지판 봉(signpost)이 있다면?
		if area.is_in_group("signpost"):
			snap_to_post(area)
			# true를 반환하면 ItemBase에게 "나 봉에 붙었으니까 둥둥 띄우지 마!" 라고 알려줍니다.
			return true 
			
	# 봉이 없다면 false를 반환해서 ItemBase가 원래 하던 대로 길을 찾아 둥둥 띄우게 합니다.
	return false 

func snap_to_post(post_area: Area2D) -> void:
	is_attached = true
	
	# ItemBase에서 혹시라도 실행 중일지 모르는 둥둥 애니메이션 정지
	if float_tween: 
		float_tween.kill()
		
	# 1. Marker2D 위치로 슉! 날아가기
	var snap_point = post_area.get_node_or_null("Marker2D")
	if snap_point:
		var tween = create_tween()
		tween.tween_property(self, "global_position", snap_point.global_position, 0.2)
	
	# 2. 봉(post_area의 부모)에게 표지판이 꽂혔다고 알리기
	var post_logic = post_area.get_parent() 
	if post_logic.has_method("apply_sign_direction"):
		post_logic.apply_sign_direction(sign_direction)
