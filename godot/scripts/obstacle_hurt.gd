extends "res://scripts/obstacle_base.gd"

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	if not player.is_in_group("player"):
		return
	print("부상 입음")
	player.take_damage()
