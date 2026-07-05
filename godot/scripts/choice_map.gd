class_name ChoiceMap
extends Node2D

@export var num_enemy: int = 0
@export var monster_scene: PackedScene
@export var spawn_offset: float = 0

func _ready() -> void:
	EventBus.fade_in.emit(1.0)
	spawn_monsters(get_paths(), num_enemy)

func get_paths() -> Array[PathChoice]:
	var paths: Array[PathChoice] = []
	for child in get_children():
		if child is PathChoice:
			paths.append(child)
	return paths

func spawn_monsters(paths: Array[PathChoice], count: int) -> void:
	if count <= 0 or paths.is_empty():
		return
	var lengths := []
	var total := 0.0
	for p in paths:
		var l: float = maxf(p.curve.get_baked_length() - spawn_offset, 0.0)
		lengths.append(l)
		total += l
	if total <= 0.0:
		return
	var spacing := total / float(count)
	for m in count:
		var jitter := randf_range(-0.3, 0.3) * spacing
		var dist: float = clamp((m + 0.5) * spacing + jitter, 0.0, total)
		var acc := 0.0
		for i in paths.size():
			if acc + lengths[i] >= dist:
				var local_dist := dist - acc + spawn_offset
				var pos: Vector2 = paths[i].to_global(paths[i].curve.sample_baked(local_dist))
				var monster = monster_scene.instantiate()
				add_child(monster)
				monster.global_position = pos 
				monster.first_pos = pos
				break
			acc += lengths[i]
