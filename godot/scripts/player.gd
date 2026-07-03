extends Node2D

@export var map: ChoiceMap

var path_choices: Array[PathChoice]
const SPEED = 200.0
var idx = 0
enum State {ON_PATH, TO_PATH, READY}
var state = State.TO_PATH

func _ready() -> void:
	path_choices = map.get_paths()

func follow(path: PathChoice) -> void:
	#get_parent().remove_child(self)
	var new_follower = path.get_follower()
	reparent(new_follower, true)
	$Camera2D.reset_smoothing()
	state = State.TO_PATH
	
func _process(delta: float) -> void:
	if not (get_parent() is PathFollow2D):
		return
	var follower := get_parent() as PathFollow2D
	print(str(state))
	match state:
		State.ON_PATH:
			print(str(follower.progress_ratio))
			if follower and follower.progress_ratio < 1.0:
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
		
