extends "res://scripts/obstacle_base.gd"

@export var damage: int = 1

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	print("부상 입음")
	player.take_damage(damage)
