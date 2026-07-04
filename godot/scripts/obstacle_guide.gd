extends "res://scripts/obstacle_base.gd"

@export var path_up_path: NodePath
var new_path_up_weight: float
var new_path_down_weight: float

@export_enum("up", "down", "default")
var direction: String = "default"

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	if not player.is_in_group("player"):
		return
	
	var main := get_tree().current_scene
	var path_up := main.get_node_or_null("MapBase/PathUp") as PathChoice
	var path_down := main.get_node_or_null("MapBase/PathDown") as PathChoice

	if path_up == null:
		push_error("MapBase/PathUp을 찾지 못함")
		return
		
	match direction:
		"default":
			new_path_up_weight = 1.0
			new_path_down_weight = 1.0
		"up":
			new_path_up_weight = 1.0
			new_path_down_weight = 0.0
		"down":
			new_path_up_weight = 0.0
			new_path_down_weight = 1.0

	path_up.prob_weight = new_path_up_weight
	path_down.prob_weight = new_path_down_weight
	print("PathUp prob_weight: ", path_up.prob_weight)
	print("PathDown prob_weight: ", path_down.prob_weight)
