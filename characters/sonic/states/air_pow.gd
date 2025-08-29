extends BaseAttack

func _enter(data := {}):
	super._enter(data)
	root.velocity.y = -24
	root.velocity.x = clamp(root.velocity.x, -5, 5)
	root.velocity.z = clamp(root.velocity.z, -5, 5)
	root.deceleration_enabled = false


func _step():
	super._step()
	if root.is_on_floor():
		root.velocity.y = 17
		root.velocity.x = attack_direction.x * 2
		root.velocity.z = attack_direction.y * 2
	
	if parent.state_time % 4 == 0 and get_current_phase() == active_phase:
		reactivate_hitbox()


func _exit(next_state):
	super._exit(next_state)
	root.deceleration_enabled = true
