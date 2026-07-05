extends Control

@export_file("*.tscn")
var next_scene_path: String = "res://scenes/game_over.tscn"

@export var typing_speed: float = 35.0

@onready var illustration: TextureRect = $Illustration
@onready var text_box: Control = $TextBox
@onready var dialogue_text: RichTextLabel = $TextBox/MarginContainer/DialogueText
@onready var click_hint: Label = $ClickHint

@export var fade_time: float = 0.25

@onready var transition_fade: ColorRect = $TransitionFade
var is_transitioning: bool = false

var cutscene_data: Array[Dictionary] = [
	{
		"image": preload("res://images/cuts/배드 엔딩.png"),#빛
		"text": "소녀는 방으로 돌아오지 못했다. 그녀에겐 더 큰 행운이 필요했던 것 같다."
	},
	{
		"image": preload("res://images/cuts/배드 엔딩.png"),#빛
		"text": "그녀에겐 더 큰 행운이 필요했던 것 같다."
	},
	{
		"fade": true,
		"text": ""
	},
]

var scene_index: int = 0
var is_typing: bool = false
var visible_count: float = 0.0
var full_text_length: int = 0


func _ready() -> void:
	transition_fade.color = Color.BLACK
	transition_fade.modulate.a = 1.0

	show_scene(0)
	await fade_from_black()


func _process(delta: float) -> void:
	if not is_typing:
		return

	visible_count += typing_speed * delta
	dialogue_text.visible_characters = int(visible_count)

	if dialogue_text.visible_characters >= full_text_length:
		finish_typing()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			get_viewport().set_input_as_handled()
			advance_cutscene()

	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		advance_cutscene()


func advance_cutscene() -> void:
	if is_transitioning:
		return

	if is_typing:
		finish_typing()
		return

	scene_index += 1

	if scene_index >= cutscene_data.size():
		end_cutscene()
		return

	var next_data := cutscene_data[scene_index]
	var use_fade: bool = next_data.get("fade", false)

	if use_fade:
		await transition_to_scene(scene_index)
	else:
		show_scene(scene_index)


func show_scene(index: int) -> void:
	var data := cutscene_data[index]

	var image = data.get("image", null)
	var text: String = data.get("text", "")

	if image == null:
		illustration.texture = null
		illustration.visible = false
	else:
		illustration.texture = image
		illustration.visible = true

	text_box.visible = text != ""
	dialogue_text.text = text
	dialogue_text.visible_characters = 0

	visible_count = 0.0
	full_text_length = text.length()

	click_hint.visible = false

	if full_text_length > 0:
		is_typing = true
	else:
		is_typing = false
		click_hint.visible = true


func finish_typing() -> void:
	is_typing = false
	dialogue_text.visible_characters = -1
	click_hint.visible = true


func end_cutscene() -> void:
	if next_scene_path == "":
		return

	get_tree().call_deferred("change_scene_to_file", next_scene_path)
	
func transition_to_scene(index: int) -> void:
	is_transitioning = true
	click_hint.visible = false

	await fade_to_black()

	show_scene(index)

	await fade_from_black()

	is_transitioning = false


func transition_to_end() -> void:
	is_transitioning = true
	click_hint.visible = false

	await fade_to_black()

	end_cutscene()


func fade_to_black() -> void:
	var tween := create_tween()
	tween.tween_property(transition_fade, "modulate:a", 1.0, fade_time)
	await tween.finished


func fade_from_black() -> void:
	var tween := create_tween()
	tween.tween_property(transition_fade, "modulate:a", 0.0, fade_time)
	await tween.finished
