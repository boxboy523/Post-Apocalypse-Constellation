extends Camera2D
@export var speed: float = 400.0
@export var min_x: float
@export var max_x: float

func _process(delta: float) -> void:
	var direction := Input.get_axis("ui_right", "ui_left")
	global_position.x -= direction * speed * delta
	global_position.x = clamp(global_position.x, min_x, max_x)
