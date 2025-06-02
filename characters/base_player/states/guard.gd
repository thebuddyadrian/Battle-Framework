extends BaseState

var startup_frames = 6
var guard_frames = 16
var recovery_frames = 10


func _enter(data = {}):
	root.animplayer.play("Guard")


func _step():
	# When in guard frames, change hurtbox to shield mode
	$"../../PlayerSprite/Misc_Effects".show()
	$"../../PlayerSprite/Misc_Effects".position = Vector3(-0.039,0.137,0.0)
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
	$"../../PlayerSprite/Misc_Effects".hide()
	root.hurtbox.mode = Hurtbox.MODE.NORMAL
