extends Node2D

@export var max_hp: int = 3
var hp: int = max_hp
@export var max_spare_hp: int = 2
var spare_hp: int = 0

var is_dead = false


@export var isInjured: bool = false
@onready var anim_sprite = $"../AnimatedSprite2D"
var player

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
	hp = GameState.hp
	spare_hp = GameState.spare_hp
	EventBus.health_changed.emit(hp + spare_hp)
	player = get_parent().get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### 체력 관련 ###
func take_damage() -> void:
	if is_dead:
		return
	if spare_hp > 0:
		spare_hp -= 1
		
		print("추가hp소모")
	else:
		hp -= 1
		print("대미지 받음. 현재 체력: ", hp, "/", max_hp)
		if hp <= 0:
			is_dead = true
			print("사망")
			anim_sprite.play("fall")
			await anim_sprite.animation_finished
			print("game over")
			EventBus.fade_out.emit(1.0)
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file.call_deferred("res://scenes/game_over.tscn")
			return
		else:
			player
	EventBus.health_changed.emit(hp + spare_hp)
	if hp < max_hp:
		isInjured = true
		print("부상")
		EventBus.change_status.emit("부상")
		EventBus.say.emit("아야야… 인생…")
	var last_anim = anim_sprite.animation
	anim_sprite.play("trapped")
	await anim_sprite.animation_finished
	print("after await")
	anim_sprite.play(last_anim)
	return

func get_medkit() -> void:
	if isInjured:
		isInjured = false
		print("부상 치료")
		EventBus.change_status.emit("러키비키!")
	if hp < max_hp:
		hp += 1
		print("체력 회복. 현재 체력: ", hp, "/", max_hp)
	elif hp >= max_hp:
		if spare_hp < max_spare_hp:
			spare_hp += 1
			print("추가 체력: ", spare_hp)
	EventBus.health_changed.emit(hp + spare_hp)
	
	
### 도주 판정 ###
func run_from_enemy(enemy_damage: int = 1):
	var chance: float = WEAPON_SUCCESS_CHANCE[weapon]
	if isInjured: chance -= 0.15
	var success: bool = randf() < chance

	print("현재 무기: ", weapon, ". 도주 성공 확률: ", chance * 100, "%")

	if success:
		print("도주 성공")
		EventBus.say.emit("헉 헉… 살았다. 오늘 운은 다 쓴 거 아냐?")
		if weapon != "none":
			if weapon == "knife":
				anim_sprite.play("knife_attack")
			if weapon == "bat":
				anim_sprite.play("bat_attack")
			if weapon == "crowbar":
				anim_sprite.play("knife_attack")
			await anim_sprite.animation_finished	
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
	
