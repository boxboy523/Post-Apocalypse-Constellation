extends Node2D

@export var map: ChoiceMap
var new_map: ChoiceMap

var path_choices: Array[PathChoice]
const SPEED = 200.0
var idx = 0
enum PlayerState {ON_PATH, TO_PATH, READY}
var state = PlayerState.TO_PATH

func _ready() -> void:
	path_choices = map.get_paths()

func follow(path: PathChoice) -> void:
	#get_parent().remove_child(self)
	var new_follower = path.get_follower()
	reparent(new_follower, true)
	$Camera2D.reset_smoothing()
	state = PlayerState.TO_PATH

func _process(delta: float) -> void:
	if not (get_parent() is PathFollow2D):
		return
	var follower := get_parent() as PathFollow2D
	print(str(state))
	match state:
		PlayerState.ON_PATH: # 플레이어가 경로를 따라 이동 중
			if not new_map: # 경로 이동 직전에 도착점 뒤에 다음 맵 생성
				var path := follower.get_parent() as PathChoice
				var last_pos = path.global_transform * path.curve.get_point_position(path.curve.get_point_count() - 1)
				if path.next_set:
					new_map = path.next_set.instantiate() as ChoiceMap
					get_tree().current_scene.add_child(new_map)
					new_map.position = last_pos
			if follower and follower.progress_ratio < 1.0:
				follower.progress += SPEED * delta # 경로를 따라 이동
			elif new_map: # 경로 끝에 도착했을 때 다음 맵으로 이동
				path_choices = new_map.get_paths()
				state = PlayerState.TO_PATH
				map = new_map
				new_map = null
		PlayerState.TO_PATH: # 플레이어가 경로의 시작점으로 이동 중
			position = position.move_toward(Vector2.ZERO, SPEED * delta)
			if position == Vector2.ZERO:
				state = PlayerState.READY
		_:
			pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("choose_path_1"): # 경로 1번
		follow(path_choices[0])
	elif event.is_action_pressed("choose_path_2"): # 경로 2번
		follow(path_choices[1])
	if event.is_action_pressed("start_path") and state == PlayerState.READY: # 이동 시작
		state = PlayerState.ON_PATH
