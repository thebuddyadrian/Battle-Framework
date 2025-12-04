extends BaseAttack


func _phase_changed():
	if get_current_phase_name() == "active":
		root.play_voice_clip("shadow/shadow_heavy")

func _step():
	if get_current_phase() == active_phase:
		root.velocity.y = 1
		root.gravity_scale = 0.5
	super._step()


func _exit(next_state):
	root.gravity_scale = 1
	super._exit(next_state)
