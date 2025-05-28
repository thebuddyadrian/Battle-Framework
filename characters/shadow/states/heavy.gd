extends BaseAttack



func _step():
	if get_current_phase() == active_phase:
		root.velocity.y = 1
		root.gravity_scale = 0.5
	super._step()


# func _phase_changed():
#     if get_current_phase() == active_phase:
#         root.gravity_scale = 0.5


func _exit(next_state):
	super._exit(next_state)
	root.gravity_scale = 1
