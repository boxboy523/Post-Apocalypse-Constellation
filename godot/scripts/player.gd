extends PathFollow2D

@export var current_path: PathChoice
@export var bubble: Control

@onready var anim_sprite = $"LerfFollow/AnimatedSprite2D"
@onready var logic = $"LerfFollow/PlayerLogic"

var path_choices: Array[PathChoice]
const SPEED = 130.0
var idx = 0
# READY -> ON_PATH -> FINISHED -> -> READY -> ON_PATH -> FINISHED ... -> END
enum PlayerState {ON_PATH, READY, END, FINISHED}
var state = PlayerState.READY

var stop = false

func _ready() -> void:
	global_position = current_path.to_global(current_path.curve.get_point_position(0))
	$LerfFollow.global_position = global_position
	follow.call_deferred(current_path)
	anim_sprite.play('idle')
	say("오늘은 운이 좋았으면 좋겠다...")
	EventBus.say.connect(say)

func follow(path: PathChoice) -> void:
	var pos = global_position
	reparent(path, true)
	self.progress = 0.0
	global_position = pos
	current_path = path
	path_choices = current_path.get_paths()

func stop_event(time: float):
	print("stopevent: ", time)
	stop = true
	anim_sprite.play('idle')
	await get_tree().create_timer(time).timeout
	if logic.is_dead:
		return
	stop = false
	anim_sprite.play('walk')

func _process(delta: float) -> void:
	if not (current_path is PathChoice) or stop:
		return
	#print(state)
	match state:
		PlayerState.ON_PATH: # 플레이어가 경로를 따라 이동 중
			if self.progress_ratio < 1.0:
				self.progress += SPEED * delta # 경로를 따라 이동
			else:
				anim_sprite.play('idle')
				if path_choices.size() == 0 and (not current_path.next_set):
					state = PlayerState.END
				else:
					state = PlayerState.FINISHED
		PlayerState.FINISHED:
			if current_path.next_set:
				EventBus.fade_out.emit(1.0)
				await get_tree().create_timer(1.0).timeout
				get_tree().change_scene_to_packed(current_path.next_set)
				return
			var next_path = current_path.get_random_path()
			follow(next_path)
			state = PlayerState.READY
		PlayerState.READY:
			if not stop:
				state = PlayerState.ON_PATH
				anim_sprite.play('walk')
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
		anim_sprite.play('walk')
	elif event.is_action_pressed("start_path"):
		print("스페이스바 눌렸지만 상태가 READY가 아님. 현재 상태: ", state)
		
		

func say(content: String):
	bubble.set_content(content)
	bubble.fade_in()
	await get_tree().create_timer(1.5).timeout
	bubble.fade_out()
