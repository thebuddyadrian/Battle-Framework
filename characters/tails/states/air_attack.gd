extends BaseAttack


func _enter(data={}):
	super._enter(data)
	root.set_action_enabled("move", true)
	root.gravity_scale = 0.3


func _step():
	super._step()
	if get_current_phase() == active_phase:
		root.velocity.y = 2
	if parent.state_time % 8 == 0 and get_current_phase() == active_phase:
		reactivate_hitbox()


func _exit(next_state):
	super._exit(next_state)
	root.gravity_scale = 1
	root.max_speed_scale = 1
	root.disable_all_actions()
