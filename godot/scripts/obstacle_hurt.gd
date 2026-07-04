extends "res://scripts/obstacle_base.gd"

func _ready() -> void:
	stop_time = 1.0
	super._ready()

func _on_player_entered(player) -> void:
	player.take_damage()
