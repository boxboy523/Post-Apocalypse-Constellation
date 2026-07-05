extends ItemBase
class_name ItemPot

var is_falling: bool = false

# 🌟 기존의 '시간(fall_speed)' 대신 '속도(fall_speed_px)'로 변경했습니다.
# 거리에 상관없이 일정한 속도로 떨어지게 하기 위함입니다. (값이 클수록 빠릅니다)
@export var fall_speed_px: float = 750.0 

@export var broken_texture: Texture2D
@onready var sprite: Sprite2D = $Sprite2D 

func _ready() -> void:
	super._ready()
	area_entered.connect(_on_area_entered)
	# 🌟 Path가 Area2D가 아니라 TileMap이나 StaticBody2D일 경우를 대비해 body_entered도 연결합니다.
	body_entered.connect(_on_body_entered)

func _check_world_interaction() -> bool:
	start_falling()
	return true 

func start_falling() -> void:
	if is_falling:
		return
	is_falling = true
	
	if float_tween: 
		float_tween.kill()
		
	float_tween = create_tween()
	
	# 🌟 바닥을 만날 때까지 끝없이 떨어지도록 목표 y좌표를 아주 아래(+2000)로 잡습니다.
	var target_y = global_position.y + 2000.0
	var fall_time = 2000.0 / fall_speed_px # 일정한 속도로 떨어지도록 시간 자동 계산
	
	float_tween.tween_property(self, "global_position:y", target_y, fall_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# 만약 2000픽셀을 떨어지는 동안 아무것도 안 닿았다면 안전장치로 그냥 깨지게 합니다.
	float_tween.tween_callback(_trigger_break)

func _on_area_entered(area: Area2D) -> void:
	if not is_falling: return
		
	# 1. 플레이어 감지 (플레이어는 깨진 파편 없이 즉시 삭제되므로 이것만 따로 처리)
	var player = area.get_parent().get_parent().get_parent()
	if player != null and player.is_in_group("player"):
		_trigger_hurt(player, area.get_parent())
		return
		
	# 2. 좀비 감지 시 사망 함수 미리 실행 (여기선 return 안 하고 아래로 통과!)
	if area.is_in_group("zombie") or area.has_method("die"):
		area.die()
	elif area.get_parent() and (area.get_parent().is_in_group("zombie") or area.get_parent().has_method("die")):
		area.get_parent().die()

	# 3. 🌟 [하나로 모은 깨짐 조건] 바닥이거나, 경로거나, 좀비였다면 무조건 쨍그랑!
	if area.is_in_group("crashground") or area.is_in_group("path") or area.is_in_group("zombie"):
		_trigger_break()


func _on_body_entered(body: Node2D) -> void:
	if not is_falling: return
		
	# 1. 물리 바디 좀비 감지 시 사망 함수 미리 실행
	if body.is_in_group("zombie") or body.has_method("die"):
		body.die()
		
	# 2. 🌟 [하나로 모은 깨짐 조건] 바닥, 타일맵, 경로, 좀비 중 하나라도 해당하면 쨍그랑!
	if body.is_in_group("crashground") or body.is_in_group("path") or body is TileMap or body.is_in_group("zombie"):
		_trigger_break()

func _trigger_hurt(player, player_logic) -> void:
	print("화분이 플레이어에게 적중했습니다! (즉시 파괴)")
	
	if player.has_method("stop_event"):
		player.stop_event(1.0)
		
	if player_logic.has_method("take_damage"):
		player_logic.take_damage()
	elif player.has_method("take_damage"):
		player.take_damage()
	else:
		print("에러: take_damage 메서드를 찾을 수 없습니다.")
		
	if float_tween:
		float_tween.kill()
	queue_free() # 플레이어에게 맞으면 깨진 이미지 없이 즉시 삭제

func _trigger_break() -> void:
	# 이미 깨짐 처리가 진행 중이면 중복 실행 방지
	if not is_falling: 
		return
	is_falling = false
	
	# 떨어지는 애니메이션을 바닥에 닿은 즉시 멈춥니다!
	if float_tween:
		float_tween.kill()
		
	print("화분이 바닥(Path)에 떨어져 깨졌습니다.")

	# 상호작용 및 충돌 감지 완전히 차단 (주울 수 없음)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if "is_cleared" in self:
		is_cleared = true 

	# 깨진 화분 이미지로 교체
	if broken_texture != null and sprite != null:
		print("✅ 이미지 교체 로직 정상 실행됨!")
		
		# 1. 애니메이션이 있다면 강제로 정지시킵니다 (덮어씌우기 방지)
		if has_node("AnimationPlayer"):
			$AnimationPlayer.stop()
			
		# 2. 스프라이트 프레임 설정을 기본값(1)으로 초기화합니다 (단일 이미지용)
		sprite.hframes = 1
		sprite.vframes = 1
		sprite.frame = 0
		sprite.region_enabled = false
		
		# 3. 깨진 이미지 적용!
		sprite.texture = broken_texture
	else:
		print("❌ 에러: broken_texture 또는 sprite가 Null입니다!")

	# 1초 유지 후 투명해지며 사라지기
	var fade_tween = create_tween()
	fade_tween.tween_interval(1.0)
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	fade_tween.tween_callback(queue_free)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	# ItemBase의 기본 드래그 로직을 먼저 실행시킵니다.
	super._input_event(viewport, event, shape_idx) 
	
	# 마우스 왼쪽 버튼을 누르는 순간(화분을 다시 잡았을 때)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_falling:
			is_falling = false
			# 떨어지던 도중이었으므로, 기존 낙하 트윈을 강제로 종료합니다.
			if float_tween:
				float_tween.kill()
			print("🏺 떨어지던 화분을 마우스로 다시 낚아챘습니다!")
