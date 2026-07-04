extends "res://scripts/obstacle_base.gd"

@export var enemy_scene: PackedScene
@export var enemy_move_time: float = 2.0
@export var enemy_spawn_offset_x: float = 1200.0

func _ready() -> void:
	stop_time = 1.0
	super._ready()

func _on_player_entered(player) -> void:
		
	print("소음 발생")
	player.add_noise_stack()
	if player.noise_triggered(1):
		queue_free()
		spawn_enemy.call_deferred()
	#일정 스택 도달 -> 적 생성

func spawn_enemy() -> void:
	if enemy_scene == null:
		print("enemy_scene이 설정되지 않음")
		return
		
	var target_pos := global_position
	var spawn_pos := target_pos
	spawn_pos.x += enemy_spawn_offset_x

	var enemy = enemy_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos
	print("enemy 스폰")
	
	enemy_come(enemy, target_pos)

func enemy_come(enemy: Area2D, target_pos: Vector2) -> void:
	var tween := enemy.create_tween()
	tween.tween_property(enemy, "global_position", target_pos, enemy_move_time)
	
