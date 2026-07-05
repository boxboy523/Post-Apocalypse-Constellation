extends "res://scripts/obstacle_base.gd"

# 🌟 핵심: 코드로 찾지 않고, 에디터 인스펙터 창에 빈칸을 뚫어줍니다!
@export var path_up: PathChoice
@export var path_down: PathChoice
@export var path_middle: PathChoice

func _ready() -> void:
	stop_time = 1.0
	super._ready()

func _on_player_entered(player) -> void:
	pass 

func apply_sign_direction(sign_dir: String) -> void:
	# 이제 에디터에서 직접 넣어줬기 때문에 무조건 찾을 수 있습니다.
	if path_up == null or path_down == null:
		push_error("경로가 설정되지 않았습니다! 맵 씬에서 봉을 클릭하고 우측 인스펙터에 Path를 넣어주세요.")
		return
		
	var new_path_up_weight: float = 0.0
	var new_path_down_weight: float = 0.0
	var new_path_middle_weight: float = 0.0
		
	match sign_dir:
		"up":
			new_path_up_weight = 1.0
		"down":
			new_path_down_weight = 1.0
		"middle":
			new_path_middle_weight = 1.0

	path_up.prob_weight = new_path_up_weight
	path_down.prob_weight = new_path_down_weight
	if path_middle != null:
		path_middle.prob_weight = new_path_middle_weight
		
	print("🎯 표지판 장착 완료! 적용 방향: ", sign_dir)
