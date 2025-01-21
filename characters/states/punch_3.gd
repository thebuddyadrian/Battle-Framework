extends BaseAttackStandard


func _move_setup():
	animation = "kick2"
	startup_frames = 3
	active_frames = 3
	recovery_frames = 24
	damage = 10
	knockback_power = 2
	make_standard_attack()


func _step():
	super._step()


func _exit(next_state):
	root.animplayer.stop()
	super._exit(next_state)
