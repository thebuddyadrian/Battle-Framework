extends BaseAttack


func _phase_changed():
	if get_current_phase() == active_phase:
		# <Spawn projectile here>
		root.velocity.y = 7.5
