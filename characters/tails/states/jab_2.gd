extends BaseAttack


func _step():
	super._step()
	if get_current_phase() == recovery_phase:
		if get_current_phase_time() == 2:
			reactivate_hitbox()
