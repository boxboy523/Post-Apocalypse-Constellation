extends Area2D

@export var stop_time: float = 1.0
var enabled = true

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not enabled:
		return
	var player = area.get_parent().get_parent().get_parent()
	if player == null:
		return
	if not player.is_in_group("player"):
		return
	
	enabled = false
	var player_logic = area.get_parent()

	player.stop_event(stop_time)

	_on_player_entered(player_logic)

func _on_player_entered(player) -> void:
	pass
	
