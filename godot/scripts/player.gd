extends PathFollow2D

@export var current_path: PathChoice
@export var bubble: Control

@onready var anim_sprite = $"LerfFollow/AnimatedSprite2D"
@onready var logic = $"LerfFollow/PlayerLogic"

var path_choices: Array[PathChoice]
const SPEED = 130.0
var idx = 0
# READY -> ON_PATH -> FINISHED -> -> READY -> ON_PATH -> FINISHED ... -> END
enum PlayerState {ON_PATH, READY, END, FINISHED}
var state = PlayerState.READY

var stop = false

func _ready() -> void:
    global_position = current_path.to_global(current_path.curve.get_point_position(0))
    $LerfFollow.global_position = global_position
    follow.call_deferred(current_path)
    anim_sprite.play('idle')
    EventBus.say.connect(say)
    EventBus.say.emit("오늘은 운이 좋았으면 좋겠다…")

func follow(path: PathChoice) -> void:
    var pos = global_position
    reparent(path, true)
    self.progress = 0.0
    global_position = pos
    current_path = path
    path_choices = current_path.get_paths()

func stop_event(time: float):
    print("stopevent: ", time)
    stop = true
    anim_sprite.play('idle')
    await get_tree().create_timer(time).timeout
    if logic.is_dead:
        return
    stop = false
    anim_sprite.play('walk')

func _process(delta: float) -> void:
    if not (current_path is PathChoice) or stop:
        return
    #print(state)
    match state:
        PlayerState.ON_PATH: # 플레이어가 경로를 따라 이동 중
            if self.progress_ratio < 1.0:
                self.progress += SPEED * delta # 경로를 따라 이동
            else:
                anim_sprite.play('idle')
                if path_choices.size() == 0 and (not current_path.next_set):
                    state = PlayerState.END
                else:
                    state = PlayerState.FINISHED
        PlayerState.FINISHED:
            if current_path.next_set:
                state = PlayerState.END
                EventBus.say.emit("웬일로 운빨이 좋은 하루였어. 매일 오늘 같으면 좋겠다!")
                EventBus.fade_out.emit(1.0)
                await get_tree().create_timer(1.0).timeout
                get_tree().change_scene_to_packed(current_path.next_set)
                return
            var next_path = current_path.get_random_path()
            follow(next_path)
            state = PlayerState.READY
        PlayerState.READY:
            if not stop:
                state = PlayerState.ON_PATH
                anim_sprite.play('walk')
        PlayerState.END:
            pass

func say(content: String):
    bubble.set_content(content)
    bubble.fade_in()
    await get_tree().create_timer(1.5).timeout
    bubble.fade_out()
