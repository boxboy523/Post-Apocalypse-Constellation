class_name PathChoice
extends Path2D
@export var desc: String
@export var next_set: PackedScene
@export var next_paths: Array[PathChoice] = []

var map: ChoiceMap

func instantiate_map() -> void:
	if next_set:
		map = next_set.instantiate() as ChoiceMap
		var pos = self.curve.get_point_position(self.curve.get_point_count() - 1)
		get_tree().current_scene.add_child(map)
		map.position = pos
		next_paths.append_array(map.get_paths())
	else:
		push_error("No next_set defined for PathChoice: " + str(self))

func get_paths() -> Array[PathChoice]:
	if next_set and not map:
		push_error("Map not instantiated for PathChoice: " + str(self))
		return []
	return next_paths
