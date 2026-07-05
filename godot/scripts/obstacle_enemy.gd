extends "res://scripts/obstacle_base.gd"

@export var move_range = 200.0
@export var speed: float = 100.0
@onready var anim_sprite = $AnimatedSprite2D

var first_pos: Vector2

var target: Vector2
var stop = false

func _ready() -> void:
	first_pos = global_position
	new_target.call_deferred()
	super._ready()

func stop_event(time: float):
	stop = true
	anim_sprite.play("stand")
	await get_tree().create_timer(time).timeout
	if not enabled:
		return
	new_target()
	anim_sprite.play("move")
	stop = false

func new_target():
	target = first_pos
	target.x += (randf() - 0.5) * 2 * move_range

func _process(delta: float) -> void:
	if stop:
		return
	if global_position.distance_to(target) < 4.0:
		stop_event(1.0)
	var dir := global_position.direction_to(target)
	if dir.x != 0:
		anim_sprite.flip_h = dir.x > 0
	global_position += dir * speed * delta

func _on_player_entered(player) -> void:
	player.run_from_enemy()
	queue_free()

	
