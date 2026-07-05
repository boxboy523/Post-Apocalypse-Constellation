extends Control

@export_file("*.tscn")
var next_scene_path: String = "res://scenes/main.tscn"

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
		"image": null,
		"text": "세상이 멸망했다."
	},
	{
		"image": null,
		"text": "극소수의 사람들은 운 좋게 쉘터로 들어갔지만—\n아직 도시에는, 힘겹게 살아가는 이들이 있다."
	},
	{
		"image": preload("res://images/main_character/소녀.png"),#소녀 등
		"text": "여기, 그중 한 명인 소녀가 있다."
	},
	{
		"fade": true,
		"image": preload("res://images/cuts/통지서.png"),
		"text": "그녀는 운이 나빴다."
	},
	{
		"fade": true,
		"image": preload("res://images/cuts/쫒기는 소녀.png"),
		"text": "...좀 많이 나빴다."
	},
	{
		"fade": true,
		"text": "폐허의 밤. 소녀는 작은 불빛 하나에 기대어, 오늘도 겨우 하루를 버텨냈다."
	},
	{
		"fade": true,
		"image": preload("res://images/cuts/3번컷씬.png"),
		"text": "그리고— 그 작은 점을, 내려다보는 존재가 있었다."
	},
	{
		"image": preload("res://images/cuts/3번컷씬.png"),
		"text": "성좌인, 당신이다."
	},
	{
		"image": preload("res://images/cuts/3번컷씬.png"),#빛
		"text": "이 운 없는 소녀에게—"
	},
	{
		"image": preload("res://images/cuts/3번컷씬.png"),#빛
		"text": "오늘 하루의 '행운'이 되어주세요."
	},
	{
		"fade": true,
		"text": "<소녀>\n ...오늘은 운이 좋으려나."
	},
]

var scene_index: int = 0
var is_typing: bool = false
var visible_count: float = 0.0
var full_text_length: int = 0


func _ready() -> void:
	EventBus.play_bgm.emit("title")
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
