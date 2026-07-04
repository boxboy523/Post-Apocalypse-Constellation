# 부모인 ItemBase 클래스를 상속받음!
extends ItemBase 

func _ready() -> void:
	item_id = "item_coin"

# 상속 후 coin만의 추가 기능 추가
func _on_pickup_success() -> void:
	print("🪙 짤랑! 코인을 주웠습니다.")
