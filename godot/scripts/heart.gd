extends HBoxContainer

@onready var hearts: Array[Control] = [$Heart1, $Heart2, $Heart3, $Heart4, $Heart5]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_health(3)
	EventBus.health_changed.connect(_set_health)
	
func _set_health(health: int):
	for i in range(5):
		hearts[i].visible = false
	for i in range(health):
		hearts[i].visible = true
