extends Node2D

@export var map: ChoiceMap

var path_choices: Array[PathChoice]
var current_path: PathChoice
const SPEED = 200.0
var idx = 0
enum PlayerState {ON_PATH, TO_PATH, READY, FINISHED, END}
var state = PlayerState.FINISHED

func _ready() -> void:
	path_choices = map.get_paths()

func follow(path: PathChoice) -> void:
	var pos = global_position
	current_path = path
	reparent(path, true)
	global_position = pos
	$"LerfFollow/Camera2D".reset_smoothing()
	self.progress = 0.0
	state = PlayerState.TO_PATH

func _process(delta: float) -> void:
	if not (get_parent() is PathChoice):
		return
	match state:
		PlayerState.ON_PATH: # 플레이어가 경로를 따라 이동 중
			if current_path.next_set and not current_path.map: # 다음 맵 생성
				current_path.instantiate_map()
			if self.progress_ratio < 1.0:
				self.progress += SPEED * delta # 경로를 따라 이동
			else:
				path_choices = current_path.get_paths() # 다음 경로 로드
				if path_choices.size() == 0:
					state = PlayerState.END
				else:
					follow(path_choices[0])
					state = PlayerState.FINISHED
		PlayerState.TO_PATH: # 플레이어가 경로의 시작점으로 이동 중
			position = position.move_toward(current_path.curve.get_point_position(0), SPEED * delta)
			if position == current_path.curve.get_point_position(0):
				state = PlayerState.READY
		_:
			pass

func _unhandled_input(event: InputEvent) -> void:
	if state == PlayerState.FINISHED:
		if event.is_action_pressed("choose_path_1"): # 경로 1번
			follow(path_choices[0])
		elif event.is_action_pressed("choose_path_2"): # 경로 2번
			follow(path_choices[1])
		state = PlayerState.TO_PATH
	if event.is_action_pressed("start_path") and state == PlayerState.READY: # 이동 시작
		state = PlayerState.ON_PATH
