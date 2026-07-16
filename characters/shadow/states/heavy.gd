extends BaseAttack

func _step():
	if get_current_phase() == active_phase:
		root.velocity.y = 1
		root.gravity_scale = 0.5
	if parent.state_time == 10:
		root.play_voice_clip("shadow/shadow_heavy")
	super._step()


func _exit(next_state):
	root.gravity_scale = 1
	super._exit(next_state)
