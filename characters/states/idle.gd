extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.set_actions_enabled(["move", "jump", "attack", "skill", "guard"], true)
	root.animplayer.play("Idle")


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
