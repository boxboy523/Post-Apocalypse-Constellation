class_name PathChoice
extends Path2D
@export var desc: String
@export var next_set: PackedScene

func get_follower() -> PathFollow2D:
	for child in get_children():
		if child is PathFollow2D:
			return child
	return null
