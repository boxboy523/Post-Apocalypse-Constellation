extends CharacterBody2D

@export var path_choices: Array[PathFollow2D] = []

const SPEED = 200.0
var idx = 0
enum State {ON_PATH, TO_PATH, READY}
var state = State.TO_PATH

func follow(follower: PathFollow2D) -> void:
	#get_parent().remove_child(self)
	var new_follower = follower
	reparent(new_follower, true)
	state = State.TO_PATH
	
func _process(delta: float) -> void:
	if not (get_parent() is PathFollow2D):
		return
	var follower := get_parent() as PathFollow2D
	var path = follower.get_parent() as Path2D
	print(str(position))
	match state:
		State.ON_PATH:
			if follower and follower.progress_ratio < 1.0:
				print(str(follower.progress_ratio))
				follower.progress += SPEED * delta
		State.TO_PATH:
			position = position.move_toward(Vector2.ZERO, SPEED * delta)
			if position == Vector2.ZERO:
				state = State.READY
		_:
			pass
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("choose_path_1"):
		follow(path_choices[0])
	elif event.is_action_pressed("choose_path_2"):
		follow(path_choices[1])
	if event.is_action_pressed("start_path") and state == State.READY:
		state = State.ON_PATH
		
