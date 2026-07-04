extends ColorRect

func _ready() -> void:
	self.modulate.a = 0.0
	EventBus.fade_in.connect(fade_in)
	EventBus.fade_out.connect(fade_out)

func fade_out(duration: float = 1.0):
	print("fade out")
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)
	await tween.finished

func fade_in(duration: float = 1.0):
	print("fade in")
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	await tween.finished
