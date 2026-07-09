extends Node2D

var lerp_speed = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    global_position = get_parent().global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var weight := 1.0 - exp(-lerp_speed * delta * 0.05)
    global_position = global_position.lerp(get_parent().global_position, weight)
