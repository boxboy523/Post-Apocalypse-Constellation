extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(warn)
	mouse_exited.connect(EventBus.reset_alart)


func warn():
	EventBus.alart.emit(
		"천사의 말: 이 길은 뒤는 안전해요
		가도 될거같아요!"
	)	
