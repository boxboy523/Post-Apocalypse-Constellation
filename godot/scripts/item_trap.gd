extends ItemBase
class_name ItemTrap
# 덫: 닿으면 플레이어가 아파집니다.

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# 플레이어 논리를 찾아 데미지를 줍니다.
	var player_logic = area.get_parent()
	if player_logic and player_logic.is_in_group("player"):
		player_logic.take_damage()
		if player_logic and not player_logic.is_dead:
			player_logic.get_parent().get_parent().stop_event(2.0)
		# 덫은 한 번 발동하면 사라집니다.
		queue_free()
