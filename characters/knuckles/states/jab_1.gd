extends BaseAttack


func _phase_changed():
	if get_current_phase_name() == "active":
		root.velocity.x = 8 * root.facing_direction.x
		root.velocity.z = 8 * root.facing_direction.y