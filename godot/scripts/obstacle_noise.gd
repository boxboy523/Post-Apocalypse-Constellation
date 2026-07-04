extends "res://scripts/obstacle_base.gd"

@export var enemy_scene: PackedScene

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	if not player.is_in_group("player"):
		return
	print("소음 발생")
	player.add_noise_stack()
	if player.noise_triggered(1):
		queue_free()
		spawn_enemy()
	#일정 스택 도달 -> 적 생성

func spawn_enemy() -> void:
	if enemy_scene == null:
		print("enemy_scene이 설정되지 않음")
		return

	var spawn_pos := global_position
	spawn_pos.x += 0

	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = spawn_pos
	print("enemy 스폰")
