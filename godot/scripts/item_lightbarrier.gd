extends ItemBase
class_name ItemLightBarrier
# 빛의 장막: 배치(사용) 시 짧은 대사를 출력합니다.
func _on_dropped_in_world() -> void:
	EventBus.say.emit("방금 뭐였지? 좀 이상한데?")
	# 기본 동작: 아이템을 월드에 둥둥 띄우기
	start_floating()
