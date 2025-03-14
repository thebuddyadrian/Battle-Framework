extends BaseAttack


func _phase_changed():
	if get_current_phase() == active_phase:
		# <Spawn projectile here>
		root.velocity.y = 12
		root.velocity.x = -root.facing_direction.x * 7
		root.velocity.z = -root.facing_direction.y * 7
