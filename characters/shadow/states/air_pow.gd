extends BaseAttack

func _enter(data := {}):
	super._enter(data)
func _step():
	super._step()
	if get_current_phase() == startup_phase:
		root.velocity = Vector3(0, 0.5, 0)
	elif get_current_phase() == active_phase:
		root.velocity = Vector3(0, -20, 0)
		if parent.state_time % 10 == 0:
			reactivate_hitbox()

func _exit(next_state):
	pass
