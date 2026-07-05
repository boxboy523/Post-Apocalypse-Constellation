extends ItemBase
class_name ItemCan

@export var enemy_scene: PackedScene

func _ready() -> void:
	super._ready() 
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# 디버그용 (작동 확인 후 지우셔도 됩니다)
	print("무언가와 겹침: ", area.name, " | 드래그중: ", is_left_dragging, " | 치워짐여부: ", is_cleared)

	# 드래그 중이거나 이미 치워졌다면 무시
	if is_left_dragging or is_cleared:
		return

	# 🌟 [수정] obstacle_base.gd와 똑같은 방식으로 노드를 찾습니다.
	var player = area.get_parent().get_parent().get_parent()
	if player == null:
		return
		
	# 🌟 [수정] 대소문자 주의! "player" (소문자)
	if not player.is_in_group("player"):
		return
		
	var player_logic = area.get_parent()

	# 🌟 [추가] obstacle_base.gd 처럼 플레이어를 잠깐 멈추게 합니다. (1.0초)
	if player.has_method("stop_event"):
		player.stop_event(1.0)

	# 소음 유발 로직 실행 (add_noise_stack은 player_logic에 있다고 가정)
	_trigger_noise(player_logic)

func _trigger_noise(player_logic) -> void:
	print("소음 발생: 깡통을 밟았습니다!")
	
	# player_logic 노드에 함수가 있는지 확인 후 실행
	if player_logic.has_method("add_noise_stack"):
		player_logic.add_noise_stack()
		
		if player_logic.has_method("noise_triggered") and player_logic.noise_triggered(1):
			spawn_enemy.call_deferred()
			queue_free() # 깡통 파괴
	else:
		print("에러: player_logic 노드에 add_noise_stack 메서드가 없습니다. 스크립트 위치를 확인하세요.")

func spawn_enemy() -> void:
	if enemy_scene == null:
		print("enemy_scene이 설정되지 않음")
		return

	var spawn_pos := global_position
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos
	enemy.first_pos = spawn_pos
	print("enemy 스폰 완료")
