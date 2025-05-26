extends BaseAttack


func _phase_changed():
	pass
func _step():
	super._step()
	if get_current_phase() == active_phase:
		root.velocity.y = 2
	if parent.state_time % 8 == 0 and get_current_phase() == active_phase:
		reactivate_hitbox()
