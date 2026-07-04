class_name PathChoice
extends Path2D
@export var desc: String
@export var next_set: PackedScene
@export var next_paths: Array[PathChoice] = []
@export var is_primary: bool = false # 이 경로가 씬에 존재할경우 자동으로 로드될지 여부

var map: ChoiceMap

func _init() -> void:
	var line = Line2D.new()
	line.points = curve.get_baked_points()
	line.width = 2.0
	line.default_color = Color(0.0, 1.0, 0.0, 1.0)
	add_child(line)


func instantiate_map() -> void:
	if next_set:
		map = next_set.instantiate() as ChoiceMap
		var pos = self.to_global(self.curve.get_point_position(self.curve.get_point_count() - 1))
		get_tree().current_scene.add_child(map)
		map.global_position = pos
		next_paths.append_array(map.get_paths())
	else:
		push_error("No next_set defined for PathChoice: " + str(self))

func get_paths() -> Array[PathChoice]:
	if next_set and not map:
		push_error("Map not instantiated for PathChoice: " + str(self))
		return []
	return next_paths
