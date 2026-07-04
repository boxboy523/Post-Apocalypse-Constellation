extends ItemBase
class_name ItemPot

var is_falling: bool = false

# 인스펙터에서 떨어지는 높이와 속도를 조절할 수 있습니다.
@export var fall_distance: float = 300.0 
@export var fall_speed: float = 0.5 

func _ready() -> void:
	super._ready()
	area_entered.connect(_on_area_entered)
	
	# 🌟 [추가] 만약 에디터 맵에 처음부터 올려뒀을 때도 곧바로 떨어지게 하려면 아래 주석을 해제하세요.
	# (인벤토리에서 꺼내 쓰는 방식만 쓴다면 주석 처리 상태로 두시면 됩니다.)
	# start_falling()

func _check_world_interaction() -> bool:
	# 마우스에서 놓는 순간 아래로 떨어지기 시작합니다.
	start_falling()
	
	# true를 반환하면 부모의 '둥둥 뜨기' 기작을 무시합니다. (절대 둥둥 뜨지 않음)
	return true 

func start_falling() -> void:
	if is_falling:
		return
		
	is_falling = true
	
	if float_tween: 
		float_tween.kill()
		
	float_tween = create_tween()
	var target_y = global_position.y + fall_distance
	
	# 아래로 갈수록 빨라지는 가속도(EASE_IN) 적용
	float_tween.tween_property(self, "global_position:y", target_y, fall_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	float_tween.tween_callback(_on_fall_finished)

func _on_fall_finished() -> void:
	is_falling = false
	# 바닥에 닿을 때까지 아무도 안 맞았다면 화분 파괴
	queue_free() 

func _on_area_entered(area: Area2D) -> void:
	print("화분 충돌 감지! 닿은 노드: ", area.name, " / 떨어지는 중인가?: ", is_falling)
	# 떨어지는 중이 아닐 때는 타격 판정 무시
	if not is_falling:
		return
		
	# obstacle 노드 탐색 방식 적용
	var player = area.get_parent().get_parent().get_parent()
	if player == null:
		return
		
	if player.is_in_group("player"):
		var player_logic = area.get_parent()
		_trigger_hurt(player, player_logic)

func _trigger_hurt(player, player_logic) -> void:
	print("화분이 플레이어에게 적중했습니다!")
	
	# 1. obstacle_base.gd 에 있던 잠깐 멈춤(stop_time = 1.0) 적용
	if player.has_method("stop_event"):
		player.stop_event(1.0)
		
	# 2. obstacle_hurt.gd 에 있던 데미지 적용
	# (take_damage 함수가 player에 있는지 player_logic에 있는지에 따라 안전하게 호출)
	if player_logic.has_method("take_damage"):
		player_logic.take_damage()
	elif player.has_method("take_damage"):
		player.take_damage()
	else:
		print("에러: take_damage 메서드를 찾을 수 없습니다.")
		
	# 적중했으므로 떨어지는 애니메이션을 즉시 멈추고 파괴
	if float_tween:
		float_tween.kill()
	queue_free()
