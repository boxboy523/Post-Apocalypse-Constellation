extends "res://scripts/obstacle_base.gd"

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	if not player.is_in_group("player"):
		print("플레이어가 아님")
		return
	player.take_damage()
