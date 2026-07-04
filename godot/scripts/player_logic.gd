extends Node2D


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
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### 체력 감소 ###
func take_damage(amount: int) -> void:
	hp -= amount
	hp = clampi(hp, 0, max_hp)

	print("대미지 받음: ", amount)
	print("현재 체력: ", hp, "/", max_hp)
	
### 도주 판정 ###
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
