extends BaseAttackStandard


func _move_setup():
	animation = "Punch1"
	startup_frames = 6
	active_frames = 3
	recovery_frames = 15
	damage = 10
	knockback_power = 2
	direction_type == DIR_TYPE.TWO_DIR
	make_standard_attack()


func _phase_changed():
	if get_current_phase() == active_phase:
		# Do stuff when the active phase starts
		pass


func _step():
	super._step()
	if get_current_phase_name() == "recovery":
		if root.input("attack", "just_pressed"):
			change_state("Punch2")


func _exit(next_state):
	root.animplayer.stop()
	super._exit(next_state)
