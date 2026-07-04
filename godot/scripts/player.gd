extends PathFollow2D

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
			# 부동소수점 비교 대신 거리 기반 비교 사용
			if position.distance_to(current_path.curve.get_point_position(0)) < 5.0:
				state = PlayerState.READY
		_:
			pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		print("플레이어가 키보드 입력을 감지함: ", event.keycode)
	if state == PlayerState.FINISHED:
		if event.is_action_pressed("choose_path_1") and path_choices.size() > 0: # 경로 1번
			print("1번 경로 선택됨")
			follow(path_choices[0])
		elif event.is_action_pressed("choose_path_2") and path_choices.size() > 1: # 경로 2번
			print("2번 경로 선택됨")
			follow(path_choices[1])
	elif state == PlayerState.READY and event.is_action_pressed("start_path"): # 이동 시작
		print("스페이스바 감지됨! 상태: ", state, " -> ON_PATH로 변경")
		state = PlayerState.ON_PATH
	elif event.is_action_pressed("start_path"):
		print("스페이스바 눌렸지만 상태가 READY가 아님. 현재 상태: ", state)
	
