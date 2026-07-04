extends "res://scripts/obstacle_base.gd"

@export_range(0.0, 1.0, 0.01)
var guide_option_1_chance: float = 0.5

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	print("표지판 확인")
	if randf() < guide_option_1_chance:
		print("1번 경로로 이동")
	else:
		print("2번 경로로 이동")
