extends PanelContainer
@export var talker: Node2D
@export var offset: Vector2
@export var content: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	offset.x += -size.x / 2
	offset.y += -size.y
	$RichTextLabel.text = content
	self.modulate.a = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = talker.get_global_transform_with_canvas().origin + offset

func set_content(new_content: String):
	content = new_content
	$RichTextLabel.text = content

func fade_in(duration: float = 0.3) -> void:
	var tween :=create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)

func fade_out(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
