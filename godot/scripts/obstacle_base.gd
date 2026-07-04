extends Area2D

@export_enum("default", "hurt", "enemy", "guide")
var obstacle_type: String = "guide"

@export var damage: int = 1
@export_range(0.0, 1.0, 0.01)
var guide_option_1_chance: float = 0.5

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()

	if not player.has_method("take_damage"):
		return

	match obstacle_type:
		"default":
			print("충돌")

		"hurt":
			print("부상 입음")
			player.take_damage(damage)

		"enemy":
			print("적과 조우")
			player.run_from_enemy(damage)
			queue_free()

		"guide":
			print("표지판에 도달")
			if randf() < guide_option_1_chance:
				print("1번")
			else:
				print("2번")
