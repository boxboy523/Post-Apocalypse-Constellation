extends Label

func _ready() -> void:
	EventBus.alart.connect(alart)

func alart(content: String):
	text = content
