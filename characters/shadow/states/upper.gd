extends BaseAttack


func _step():
	super._step()
	# Experimental: Allow jump cancels on hit
	if move_hit:
		root.set_action_enabled("jump", true)
	if parent.state_time == 1:
		root.play_voice_clip("shadow/shadow_heavy")
	