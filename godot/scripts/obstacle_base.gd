extends Area2D

@export_enum("default", "hurt", "enemy", "guide")
var obstacle_type: String = "hurt"

@export var damage: int = 1
@export_range(0.0, 1.0, 0.01)
var guide_option_1_chance: float = 0.5

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	match obstacle_type:
		"default":
			print("충돌")

		"hurt":
			print("부상 입음")
			print("대미지: ", damage)

		"enemy":
			print("적과 조우")

		"guide":
			print("표지판에 도달")

			if randf() < guide_option_1_chance:
				print("1번")
			else:
				print("2번")
