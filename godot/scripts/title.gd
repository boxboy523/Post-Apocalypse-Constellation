extends Control

@export_file("*.tscn")
var game_scene_path: String

func _ready() -> void:
	$Button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	if game_scene_path == "":
		print("게임 씬 경로가 설정되지 않음")
		return

	get_tree().change_scene_to_file(game_scene_path)
