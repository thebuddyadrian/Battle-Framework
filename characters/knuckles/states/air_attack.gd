extends BaseAttack


func _phase_changed():
	if get_current_phase() == active_phase:
		root.velocity.y = -4
