extends Node

signal health_changed(new_health)
signal fade_in(duration)
signal fade_out(duration)
signal change_status(new_state)
signal say(content)
signal alart(content)

func reset_alart():
	alart.emit("지금은 안전합니다...
아마도?"
	)

signal play_bgm(mode)
