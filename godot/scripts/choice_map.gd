class_name ChoiceMap
extends Node2D

@export var num_enemy: int = 0
@export var num_objects: int = 10
@export var monster_scene: PackedScene
@export var spawn_offset: float = 300

var object_list: Array[PackedScene] = [
	preload("res://scenes/item_can.tscn"),
	preload("res://scenes/item_glass.tscn"),
	preload("res://scenes/item_pot.tscn"),
	preload("res://scenes/item_signdown.tscn"),
	preload("res://scenes/item_signmiddle.tscn"),
	preload("res://scenes/item_signup.tscn"),
	preload("res://scenes/item_trap.tscn"),
	preload("res://scenes/obstacle_farm.tscn"),
	preload("res://scenes/obstacle_heal.tscn")
]

func _ready() -> void:
	EventBus.fade_in.emit(1.0)
	spawn_monsters.call_deferred(get_paths(), num_enemy)
	spawn_randobj.call_deferred(get_paths(), num_objects)

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

func spawn_randobj(paths: Array[PathChoice], count: int) -> void:
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
				var idx = randi_range(0, object_list.size() - 1)
				if idx > 3 and idx <= 6:
					idx = randi_range(0, object_list.size() - 1) # reroll for reduce sign rate
				var object = object_list[idx].instantiate()
				if idx == 3: #pot
					pos.y += 500
				add_child(object)
				object.global_position = pos
				object.z_index = 1
				break
			acc += lengths[i]
