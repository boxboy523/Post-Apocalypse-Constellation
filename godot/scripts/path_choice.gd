class_name PathChoice
extends Path2D
@export var desc: String
@export var prob_weight: float = 1.0
@export var next_set: PackedScene
@export var next_paths: Array[PathChoice] = []
var next_probs: Array[float] = []
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

func get_path_probabilities() -> Array[float]:
	if next_set and not map:
		push_error("Map not instantiated for PathChoice: " + str(self))
		return []
	var paths = get_paths()
	var total_weight = 0.0
	for path in paths:
		total_weight += path.prob_weight
	var probabilities: Array[float] = []
	for path in paths:
		probabilities.append(path.prob_weight / total_weight)
	self.next_probs = probabilities
	return probabilities

func get_random_path() -> PathChoice:
	if len(next_paths) == 0:
		push_error("No next paths available for PathChoice: " + str(self))
		return null
	if len(next_probs) == 0:
		get_path_probabilities()
	var rand = randf()
	var cumulative_prob = 0.0
	for i in range(len(next_paths)):
		cumulative_prob += next_probs[i]
		if rand < cumulative_prob:
			return next_paths[i]
	return next_paths[-1] # Fallback in case of rounding errors
