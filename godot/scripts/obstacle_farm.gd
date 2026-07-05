extends "res://scripts/obstacle_base.gd"

@export_enum("weapon", "medkit", "random")
var farm_type: String = "weapon"

@export_enum("knife", "bat", "crowbar")
var weapon_reward: String = "knife"

# 랜덤 더미 확률
@export var weight_medkit: int = 15
@export var food: int = 20
@export var water: int = 20
@export var supply: int = 20
@export var weight_none: int = 25

var used: bool = false

func _ready() -> void:
	stop_time = 1.0
	super._ready()

func _on_player_entered(player) -> void:

	if used:
		return

	used = true

	if randf() < 0.5 :
		EventBus.say.emit("이게 아직도 남아있다니! 럭키비키잖아!")

	match farm_type:
		"weapon":
			give_weapon(player)

		"medkit":
			give_medkit(player)

		"random":
			give_random_reward(player)

	queue_free()
	
func give_weapon(player) -> void:
	player.weapon = weapon_reward
	print("무기 획득: ", weapon_reward)
	print("현재 전투 성공 확률: ", player.WEAPON_SUCCESS_CHANCE[player.weapon])


func give_medkit(player) -> void:
	player.get_medkit()
	print("구상 획득")


func give_random_reward(player) -> void:
	var total_weight := weight_medkit + food + water + supply + weight_none
	var roll := randi_range(1, total_weight)

	if roll <= weight_medkit:
		give_medkit(player)
		return

	roll -= weight_medkit

	if roll <= food:
		print("음식 획득")
		# 나중에 player.get_supply_1() 같은 함수 만들면 여기서 호출
		return

	roll -= food

	if roll <= water:
		print("물 획득")
		# 나중에 player.get_supply_2() 같은 함수 만들면 여기서 호출
		return

	roll -= water

	if roll <= supply:
		print("물자 획득")
		# 나중에 player.get_supply_3() 같은 함수 만들면 여기서 호출
		return

	print("아무것도 얻지 못함")
