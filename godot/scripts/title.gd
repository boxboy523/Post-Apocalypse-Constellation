extends Control

@export_file("*.tscn")
var game_scene_path: String = "res://scenes/intro.tscn"

func _ready() -> void:
	$StartButton.pressed.connect(_on_start_button_pressed)
	$ExitButton.pressed.connect(_on_exit_button_pressed)
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
