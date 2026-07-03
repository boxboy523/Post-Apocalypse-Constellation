extends TextureRect

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not "item_coin" in inventory_manager.items:
		return null
		
	# [추가] 내 가방에서 드래그를 시작하는 "그 순간만큼은" 부모인 DropZone을 깨워서 마우스를 붙잡게 합니다!
	if get_parent() is Control:
		get_parent().mouse_filter = Control.MOUSE_FILTER_STOP
		
	var preview = TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(40, 40) 
	
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_drag_preview(preview)
	return "item_coin"
