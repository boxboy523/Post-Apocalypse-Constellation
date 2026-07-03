class_name ChoiceMap
extends Node2D

func get_paths() -> Array[PathChoice]:
	var paths: Array[PathChoice] = []
	for child in get_children():
		if child is PathChoice:
			paths.append(child)
	return paths
