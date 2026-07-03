extends TextureRect

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not "Coin" in inventorymanager.items:
		return null
		
	var preview = TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(40, 40) 
	
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	set_drag_preview(preview)
	return "Coin"
