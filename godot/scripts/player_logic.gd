extends Node2D

@export var max_hp: int = 3
var hp: int = max_hp
@export var spare_hp: int = 0

@export var isInjured: bool = false

var noise_stack: int = 0

@export_enum("none", "knife", "bat", "crowbar")
var weapon: String = "none"
const WEAPON_SUCCESS_CHANCE := {
	"none": 0.45,
	"knife": 0.50,
	"bat": 0.65,
	"crowbar": 0.80
	
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### 체력 관련 ###
func take_damage() -> void:
	if spare_hp > 0:
		spare_hp -= 1
		print("추가hp소모")
	else:
		hp -= 1
		print("대미지 받음. 현재 체력: ", hp, "/", max_hp)
	if hp < max_hp:
		isInjured = true
		print("부상")
	
func get_medkit() -> void:
	if isInjured:
		isInjured = false
		print("부상 치료")
	if hp < max_hp:
		hp += 1
		print("체력 회복. 현재 체력: ", hp, "/", max_hp)
	elif hp >= max_hp:
		spare_hp += 1
		print("추가 체력: ", spare_hp)
	
	
### 도주 판정 ###
func run_from_enemy(enemy_damage: int = 1):
	var chance: float = WEAPON_SUCCESS_CHANCE[weapon]
	if isInjured: chance -= 0.15
	var success: bool = randf() < chance

	print("현재 무기: ", weapon, ". 도주 성공 확률: ", chance * 100, "%")

	if success:
		print("도주 성공")
	else:
		print("도주 실패")
		take_damage()
		
### 소음 관련 ###
func add_noise_stack() -> void :
	noise_stack += 1
	print("소음 스택 +1")
	
func noise_triggered(trigger: int) -> bool:
	if noise_stack == trigger:
		print("noise triggered.")
		return true
	return false
	
