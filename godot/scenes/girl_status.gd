extends Label

func _ready() -> void:
	EventBus.change_status.connect(change_status)
	change_status("오늘 운이 좋기를 바라는 중")

func change_status(new_state: String):
	text = "상태: " + new_state
