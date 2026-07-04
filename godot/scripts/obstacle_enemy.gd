extends "res://scripts/obstacle_base.gd"

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	if not player.is_in_group("player"):
		return
		
	print("적과 조우")
	#플레이어 부상 여부에 따라 확률 변동되도록 나중에 추가
	player.run_from_enemy()
