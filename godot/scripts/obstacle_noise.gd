extends "res://scripts/obstacle_base.gd"

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	print("소음 발생")
	print("소음 스택 +1")
	#일정 스택 도달 -> 적 생성
