extends Control

@export var slot_size: int = 64

func _ready() -> void:
	inventory_manager.ui = self
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _exit_tree() -> void:
	inventory_manager.ui = null

# 인벤토리 격자와 아이콘을 그리는 역할만 수행
func _draw() -> void:
	var width = inventory_manager.width
	var height = inventory_manager.height
	var items = inventory_manager.items

	for y in range(height):
		for x in range(width):
			var rect = Rect2(x * slot_size, y * slot_size, slot_size, slot_size)
			draw_rect(rect, Color(1.0, 1.0, 1.0, 1.0), true)  # 슬롯 배경
			draw_rect(rect, Color(0.0, 0.0, 0.0, 1.0), false) # 슬롯 테두리
			
			var index = y * width + x
			if index < items.size() and items[index]:
				var icon = items[index].icon
				if icon:
					draw_texture_rect(icon, rect, false)
