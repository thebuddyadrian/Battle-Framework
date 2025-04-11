extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.animplayer.play("Falling")
	root.set_actions_enabled(["move", "air_action", "attack", "skill"], true)


func _step():
	root.update_facing_direction_2d()
	# Landing
	if root.is_on_floor():
		parent.change_state("Land")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.disable_all_actions()
	root.animplayer.stop()
	super._exit(next_state)
