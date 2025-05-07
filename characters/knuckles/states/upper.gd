extends BaseAttack


func _step():
	super._step()
	# Experimental: Allow jump cancels on hit
	if move_hit:
		root.set_action_enabled("jump", true)