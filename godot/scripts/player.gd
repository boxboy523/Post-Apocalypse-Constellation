extends Node2D

@export var map: ChoiceMap

var path_choices: Array[PathChoice]
var current_path: PathChoice
const SPEED = 200.0
var idx = 0
# READY -> ON_PATH -> READY ... -> END
enum PlayerState {ON_PATH, READY, END, FINISHED}
var state = PlayerState.READY

func _ready() -> void:
	call_deferred("follow", map.get_paths()[0])	

func follow(path: PathChoice) -> void:
	if path.next_set and not path.map: # 다음 맵 생성
		path.instantiate_map()
	var pos = global_position
	reparent(path, true)
	self.progress = 0.0
	global_position = pos
	current_path = path
	path_choices = current_path.get_paths()
	$"LerfFollow/Camera2D".reset_smoothing()

func _process(delta: float) -> void:
	if not (current_path is PathChoice):
		return
	print(state)
	match state:
		PlayerState.ON_PATH: # 플레이어가 경로를 따라 이동 중
			if self.progress_ratio < 1.0:
				self.progress += SPEED * delta # 경로를 따라 이동
			else:
				if path_choices.size() == 0:
					state = PlayerState.END
				else:
					state = PlayerState.FINISHED
		PlayerState.FINISHED:
			var next_path = current_path.get_random_path()
			follow(next_path)
			state = PlayerState.READY
		PlayerState.READY:
			pass
		PlayerState.END:
			pass
		

func _unhandled_input(event: InputEvent) -> void:
	#if state == PlayerState.FINISHED:
		#if event.is_action_pressed("choose_path_1"): # 경로 1번
			#follow(path_choices[0])
		#elif event.is_action_pressed("choose_path_2"): # 경로 2번
			#follow(path_choices[1])
		#state = PlayerState.TO_PATH
	if event.is_action_pressed("start_path") and state == PlayerState.READY: # 이동 시작
		state = PlayerState.ON_PATH
