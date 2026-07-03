extends Area2D

@export var item_name: String = "Coin"

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			inventorymanager.add_item(item_name)
			queue_free()
