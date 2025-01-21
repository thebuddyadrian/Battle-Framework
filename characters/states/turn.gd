extends BaseState


func _enter(data = {}):
	root.animplayer.play("Turn")
	root.set_actions_enabled(["move", "jump", "attack", "skill", "guard"], true)


func _step():
	if parent.state_time >= 9:
		parent.change_state("Move")


func _exit(next_state):
	# Don't face in the opposite direction when doing an Upper attack
	if !next_state.name == "Upper":
		root.flip_facing_direction_2d()
	root.disable_all_actions()
	super._exit(next_state)
