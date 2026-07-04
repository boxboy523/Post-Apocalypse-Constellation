extends Camera2D

@export var speed: float = 5.0

var half: Vector2

func _ready() -> void:
	half = get_viewport_rect().size / 2 / zoom


func _process(delta: float) -> void:
	var direction := Input.get_axis("ui_right", "ui_left")
	position.x -= direction * speed * delta
	print(position.x, "left: ", limit_left, "right: ", limit_right, "half: ", half)
	position.x = clamp(position.x, limit_left + half.x, limit_right - half.x)
