extends Button


func _ready():
	self.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
