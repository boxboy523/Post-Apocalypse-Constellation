extends ItemBase
class_name ItemCoin

@export var coin_amount: int = 10

func _on_dropped_in_world() -> void:
	print("🪙 [ItemCoin] 코인은 부모의 '둥둥 뜨는 로직'을 무시하고 제자리에 안착합니다.")
	_play_drop_ground_effect()

func _play_drop_ground_effect() -> void:
	if float_tween:
		float_tween.kill()
	
	float_tween = create_tween()
	# 현재 원래 스케일 기준으로 찌그러졌다가 (x 1.2, y 0.8)
	scale = original_scale * Vector2(1.2, 0.8) 
	
	# 다시 '원래 스케일(original_scale)'로 튕기듯 복구!
	float_tween.tween_property(self, "scale", original_scale, 0.15).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT) 
	
	print("🪙 코인이 현재 마우스 드롭 위치에 고정되었습니다: ", global_position)
