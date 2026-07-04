class_name PathChoice
extends Path2D
@export var desc: String
@export var prob_weight: float = 1.0
@export var next_set: PackedScene
@export var next_paths: Array[PathChoice] = []
var next_probs: Array[float] = []

func _init() -> void:
	var line = Line2D.new()
	line.points = curve.get_baked_points()
	line.width = 2.0
	line.default_color = Color(0.0, 1.0, 0.0, 1.0)
	add_child(line)

func get_paths() -> Array[PathChoice]:
	if next_set:
		return []
	return next_paths

func get_path_probabilities() -> Array[float]:
	if next_set:
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
