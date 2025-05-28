extends BaseAttack
func _enter(data := {}):
	super._enter(data)
func _step():
	super._step()
	if get_current_phase() == startup_phase:
		root.velocity = Vector3(0, 0, 0)
	elif get_current_phase() == startup_phase:
		root.velocity = Vector3(0, 0, 0)
	elif get_current_phase() == active_phase:
		pass
func _exit(next_state):
	pass
