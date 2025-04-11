extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.set_actions_enabled(["move", "air_dash", "attack", "skill"], true)
	root.animplayer.play("Jump")
	root.play_sound_effect("jump")
	root.velocity.y = root.JUMP_VELOCITY


func _step():
	root.update_facing_direction_2d()
	# Falling
	if root.velocity.y < 0 && !root.is_on_floor():
		parent.change_state("Fall")
	# Landing
	if root.is_on_floor():
		parent.change_state("Land")

func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.animplayer.stop()
	root.disable_all_actions()
	super._exit(next_state)
