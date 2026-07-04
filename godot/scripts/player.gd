extends PathFollow2D

@export var map: ChoiceMap
@export var bubble: Control

var path_choices: Array[PathChoice]
var current_path: PathChoice
const SPEED = 130.0
var idx = 0
# READY -> ON_PATH -> FINISHED -> -> READY -> ON_PATH -> FINISHED ... -> END
enum PlayerState {ON_PATH, READY, END, FINISHED}
var state = PlayerState.READY

var stop = false

func _ready() -> void:
	$LerfFollow.global_position = global_position
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

func stop_event(time: float):
	stop = true
	await get_tree().create_timer(time).timeout
	stop = false

func _process(delta: float) -> void:
	if not (current_path is PathChoice) or stop:
		return
	#print(state)
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
	if event.is_action_pressed("choose_path_1"): # 경로 1번
		say("이게 뭐야?")
		#elif event.is_action_pressed("choose_path_2"): # 경로 2번
			#follow(path_choices[1])
		#state = PlayerState.TO_PATH
	if event.is_action_pressed("start_path") and state == PlayerState.READY and not stop: # 이동 시작
		state = PlayerState.ON_PATH
	elif event.is_action_pressed("start_path"):
		print("스페이스바 눌렸지만 상태가 READY가 아님. 현재 상태: ", state)
		
		

func say(content: String):
	bubble.set_content(content)
	bubble.fade_in()
	await get_tree().create_timer(1.5).timeout
	bubble.fade_out()
	
