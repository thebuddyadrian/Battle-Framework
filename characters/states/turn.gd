extends BaseState


func _enter(data = {}):
	if data.get("run", false):
		root.animplayer.play("RunTurn")
	else:
		root.animplayer.play("Turn")
	# Make turn faster
	root.acceleration_scale = 2.0
	root.deceleration_scale = 1.5
	root.set_actions_enabled(["move", "jump", "attack", "skill", "guard"], true)


func _step():
	if parent.state_time >= 9:
		parent.change_state("Move")


func _exit(next_state):
	root.acceleration_scale = 1.0
	root.deceleration_scale = 1.0
	# Don't face in the opposite direction when doing an Upper attack
	if !next_state.name == "Upper":
		root.flip_facing_direction_2d()
	root.disable_all_actions()
	super._exit(next_state)
