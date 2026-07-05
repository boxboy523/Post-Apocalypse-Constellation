extends Label

func _ready() -> void:
	EventBus.change_status.connect(change_status)

func change_status(new_state: String):
	text = "상태: " + new_state
