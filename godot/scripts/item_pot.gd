extends ItemBase
class_name ItemPot

# 부모(ItemBase)가 마우스를 놓았을 때 이 함수를 먼저 실행해 줍니다.
func _check_world_interaction() -> bool:
	# TODO: 나중에 여기에 '밑에 몹이 있는지' 검사하는 로직을 넣을 예정입니다.
	# 지금은 false를 반환하여, 부모의 기본 동작인 '둥둥 뜨기'가 실행되게 합니다.
	return false
