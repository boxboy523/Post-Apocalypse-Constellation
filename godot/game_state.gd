extends Node

var hp: int = 3
var spare_hp: int = 0
var action_point: float = 100.0
var max_action_point: float = 100.0
var ap_regen: float = 1.0
var char_state: String = "러키비키!"

func _process(delta: float) -> void:
	if max_action_point > action_point:
		action_point += delta * ap_regen
		if action_point > max_action_point:
			action_point = max_action_point
