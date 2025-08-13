extends BaseState

var startup_frames = 6
var guard_frames = 16
var recovery_frames = 10

const GUARD_EFFECT_PATH = "res://effects/guard_effect.tscn"


func _enter(data = {}):
	root.animplayer.play("Guard")


func _step():
	if parent.state_time == startup_frames:
		root.spawn_scene("GuardEffect", GUARD_EFFECT_PATH, root.global_position)

	# When in guard frames, change hurtbox to shield mode
	if parent.state_time >= startup_frames and parent.state_time < startup_frames + guard_frames:
		root.hurtbox.mode = Hurtbox.MODE.SHIELD
	else:
		root.hurtbox.mode = Hurtbox.MODE.NORMAL

	if parent.state_time >= startup_frames + guard_frames and root.input("guard"):
		change_state("Heal")
		return

	if parent.state_time >= startup_frames + guard_frames + recovery_frames:
		change_state("Idle")
		return


func _exit(next_state: BaseState):
	root.hurtbox.mode = Hurtbox.MODE.NORMAL
