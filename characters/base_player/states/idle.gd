extends BaseState


func _enter(data = {}):
	if !root.is_on_floor():
		parent.change_state("Fall")
		return
	super._enter(data)
	root.set_actions_enabled(["move", "jump", "dash", "attack", "skill", "guard"], true)
	root.animplayer.play("Idle")
	# Reset wall bounces
	root.wall_bounces = 0
	# Reset air skills and actions
	root.air_actions_used = 0
	root.air_skills_used = 0


func _step():
	super._step()
	if root.get_input_vector() != Vector2.ZERO:
		if root.is_turning():
			parent.change_state("Turn")
		else:
			parent.change_state("Move")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.disable_all_actions()
	root.animplayer.stop()
	super._exit(next_state)
