extends Node2D

@export var map: ChoiceMap
var new_map: ChoiceMap

@export var max_hp: int = 5
var hp: int = 5

@export_enum("none", "knife", "bat", "crowbar")
var weapon: String = "none"

const WEAPON_SUCCESS_CHANCE := {
	"none": 0.45,
	"knife": 0.50,
	"bat": 0.65,
	"crowbar": 0.80
}

var path_choices: Array[PathChoice]
const SPEED = 200.0
var idx = 0
enum PlayerState {ON_PATH, TO_PATH, READY}
var state = PlayerState.TO_PATH

func _ready() -> void:
	path_choices = map.get_paths()
	hp = max_hp

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
	#print(str(state))
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
		
		
### 체력 감소 ###
func take_damage(amount: int) -> void:
	hp -= amount
	hp = clampi(hp, 0, max_hp)

	print("대미지 받음: ", amount)
	print("현재 체력: ", hp, "/", max_hp)

	if hp <= 0:
		die()

### 체력 회복 ###
func heal(amount: int) -> void:
	hp += amount
	hp = clampi(hp, 0, max_hp)

	print("회복: ", amount)
	print("현재 체력: ", hp, "/", max_hp)

### 체력 0 -> 사망 ###
func die() -> void:
	print("플레이어 사망")
	state = PlayerState.READY
	
### 도망 판정 ###
func run_from_enemy(enemy_damage: int = 1) -> bool:
	var chance: float = WEAPON_SUCCESS_CHANCE[weapon]
	var success: bool = randf() < chance

	print("현재 무기: ", weapon)
	print("도주 성공 확률: ", chance * 100, "%")

	if success:
		print("도주 성공")
		return true
	else:
		print("도주 실패")
		take_damage(enemy_damage)
		return false
