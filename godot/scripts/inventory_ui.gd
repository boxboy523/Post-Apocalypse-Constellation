extends Control
@export var slot_size: int = 64

func _ready() -> void:
	inventory_manager.ui = self
	queue_redraw()

func _exit_tree() -> void:
	inventory_manager.ui = null

func _draw() -> void:
	var width = inventory_manager.width
	var height = inventory_manager.height
	var items = inventory_manager.items
	print("📦 [InventoryUI] _draw() 호출: width=", width, ", height=", height, ", items.size()=", items.size())

	for y in range(height):
		for x in range(width):
			var rect = Rect2(x * slot_size, y * slot_size, slot_size, slot_size)
			draw_rect(rect, Color(1.0, 1.0, 1.0, 1.0), true) # Draw slot background
			draw_rect(rect, Color(0.0, 0.0, 0.0, 1.0), false) # Draw slot border
			if items[y * width + x]:
				var icon = items[y * width + x].icon
				if icon:
					draw_texture(icon, Vector2(x * slot_size, y * slot_size))
