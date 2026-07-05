extends CanvasLayer

@onready var bgm_gameplay: AudioStreamPlayer = $BGMGameplay
@onready var bgm_failure: AudioStreamPlayer = $BGMFailure
@onready var bgm_title: AudioStreamPlayer = $BGMTitle

var current_scene_file: String = ""
var current_mode: String = ""

func _ready() -> void:
	get_tree().connect("node_added", Callable(self, "_on_node_added"))
	EventBus.play_bgm.connect(Callable(self, "_on_play_bgm"))
	call_deferred("_start_bgm")

func _start_bgm() -> void:
	if bgm_gameplay.stream == null:
		print("AudioManager: bgm_gameplay stream is null")
	if bgm_failure.stream == null:
		print("AudioManager: bgm_failure stream is null")
	if bgm_title.stream == null:
		print("AudioManager: bgm_title stream is null")
	print("AudioManager: deferred start bgm")
	_update_scene_bgm()

func _on_node_added(node: Node) -> void:
	_update_scene_bgm()

func _on_play_bgm(mode: String) -> void:
	match mode:
		"failure":
			_play_failure_bgm()
		"title":
			_play_title_bgm()
		_:
			_play_gameplay_bgm()

func _update_scene_bgm() -> void:
	var scene_file = _get_current_scene_file()
	print("AudioManager: current scene file=", scene_file)
	if scene_file == current_scene_file:
		return
	current_scene_file = scene_file
	if scene_file == "":
		_stop_all_bgm()
		return
	match scene_file.get_file():
		"game_over.tscn":
			_play_failure_bgm()
		"title.tscn", "intro.tscn":
			_play_title_bgm()
		_:
			_play_gameplay_bgm()

func _get_current_scene_file() -> String:
	var scene = get_tree().get_current_scene()
	if scene == null:
		return ""
	if scene.has_method("get_filename"):
		var path = scene.get_filename()
		if path != "":
			return path
	if scene.has_meta("filename"):
		return str(scene.get_meta("filename"))
	return ""

func _play_gameplay_bgm() -> void:
	if current_mode == "gameplay":
		return
	current_mode = "gameplay"
	bgm_failure.stop()
	bgm_title.stop()
	bgm_gameplay.play()

func _play_failure_bgm() -> void:
	if current_mode == "failure":
		return
	current_mode = "failure"
	bgm_gameplay.stop()
	bgm_title.stop()
	bgm_failure.play()

func _play_title_bgm() -> void:
	if current_mode == "title":
		return
	current_mode = "title"
	bgm_gameplay.stop()
	bgm_failure.stop()
	bgm_title.play()

func _stop_all_bgm() -> void:
	if current_mode == "":
		return
	current_mode = ""
	bgm_gameplay.stop()
	bgm_failure.stop()
	bgm_title.stop()
