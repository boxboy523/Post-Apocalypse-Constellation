class_name PathChoice
extends Path2D
@export var desc: String
@export var prob_weight: float = 1.0
@export var next_set: PackedScene
@export var next_paths: Array[PathChoice] = []
var next_probs: Array[float] = []


func get_paths() -> Array[PathChoice]:
	if next_set:
		return []
	return next_paths

func get_path_probabilities() -> Array[float]:
	if next_set:
		return []
	var paths = get_paths()
	var total_weight = 0.0
	for path in paths:
		total_weight += path.prob_weight
	var probabilities: Array[float] = []
	for path in paths:
		probabilities.append(path.prob_weight / total_weight)
	self.next_probs = probabilities
	return probabilities

func get_random_path() -> PathChoice:
	if len(next_paths) == 0:
		return null
		
	# 최신 가중치 기반으로 확률 배열(next_probs) 갱신
	get_path_probabilities()
	
	# 📊 [디버그 출력 추가] 현재 선택할 수 있는 모든 길의 최종 확률을 보여줍니다.
	print("\n=== 🎲 현재 분기점의 최종 확률 계산 ===")
	print("내 현재 위치(선택을 시작하는 길): ", desc if desc else name)
	for i in range(len(next_paths)):
		var path_name = next_paths[i].desc if next_paths[i].desc else next_paths[i].name
		# 확률값에 100을 곱해서 보기 편한 % 단위로 출력합니다.
		print(" ➡️ 갈 수 있는 길 [", path_name, "] 의 확률: ", snapped(next_probs[i] * 100, 0.1), "%")
	print("=======================================")
	
	var rand = randf()
	var cumulative_prob = 0.0
	for i in range(len(next_paths)):
		cumulative_prob += next_probs[i]
		if rand < cumulative_prob:
			# 어떤 길이 최종 선택되었는지도 출력합니다.
			var chosen_name = next_paths[i].desc if next_paths[i].desc else next_paths[i].name
			print("🎯 [주사위 결과] 최종 선택된 길: ", chosen_name, "\n")
			return next_paths[i]
			
	return next_paths[-1]
