extends TextureRect

# 드롭 시 월드에 다시 스폰할 코인 씬 경로
const ITEM_COIN_SCENE = preload("res://scenes/item_coin.tscn")

var is_right_dragging: bool = false
var drag_preview: TextureRect = null

# 1️⃣ [시작] 우클릭을 누르는 순간
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		
		if not "item_coin" in inventory_manager.items:
			print("⚠️ [인벤토리] 가방에 코인이 없습니다.")
			return
		
		is_right_dragging = true
		print("🔄 [인벤토리] 우클릭 드래그 시작!")
		
		# 프리뷰 이미지 생성
		drag_preview = TextureRect.new()
		drag_preview.texture = texture
		drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		# ⭐ [해결 1] 크기를 강제로 40x40으로 고정 (원하는 크기로 조절 가능)
		drag_preview.size = Vector2(40, 40)
		drag_preview.custom_minimum_size = Vector2(40, 40)
		drag_preview.modulate.a = 0.6  # 반투명하게
		
		# 프리뷰가 마우스 클릭을 방해하지 않도록 설정
		drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# 최상위 씬 루트에 안전하게 추가
		get_tree().current_scene.add_child(drag_preview)
		
		_update_preview_position()
		get_viewport().set_input_as_handled()

# 2️⃣ [중간 과정 & 종료]
func _input(event: InputEvent) -> void:
	if not is_right_dragging:
		return
		
	# 🔄 드래그 중 (마우스 이동)
	if event is InputEventMouseMotion:
		_update_preview_position()
		
	# 🏁 드롭 (우클릭 뗌)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		is_right_dragging = false
		print("🏁 [인벤토리] 드롭!")
		
		if drag_preview:
			drag_preview.queue_free()
			drag_preview = null
		
		var item_index = inventory_manager.items.find("item_coin")
		if item_index != -1:
			inventory_manager.items.remove_at(item_index)
			
			var new_coin = ITEM_COIN_SCENE.instantiate()
			
			# 마우스가 놓인 월드 좌표 지정
			new_coin.global_position = get_tree().current_scene.get_global_mouse_position()
			
			# 메인 씬에 깔끔하게 추가 (이제 원본 씬의 0.3 크기 그대로 소환됩니다!)
			get_tree().current_scene.add_child(new_coin)
			print("🪙 [드롭 완료] 씬 기본 크기(0.3)로 코인이 생성되었습니다.")
			
		get_viewport().set_input_as_handled()

# 3️⃣ ⭐ [해결 2] 프리뷰 위치를 마우스 정중앙으로 완벽 정렬하는 함수
func _update_preview_position() -> void:
	if drag_preview and drag_preview.get_parent():
		# 프리뷰가 속한 부모 기준의 마우스 좌표를 계산해서 좌표계가 깨지는 걸 방지합니다.
		var mouse_pos = drag_preview.get_parent().get_local_mouse_position()
		
		# 마우스 위치에서 프리뷰 크기의 '정확히 절반'을 빼주어 정중앙에 고정합니다.
		drag_preview.position = mouse_pos - (drag_preview.size / 2)
