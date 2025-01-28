extends BaseState

const STOP_THRESHOLD = 6.0

var turn: bool = false

func _enter(data = {}):
	super._enter(data)
	root.set_actions_enabled(["move", "jump", "attack", "skill", "dash", "guard"], true)


func _step():
	# Animation
	if parent.state_time < 4:
		root.animplayer.play("MoveTransition")
	else:
		root.animplayer.play("Moving")
	# Stopping
	if root.get_input_vector() == Vector2.ZERO:
		if root.velocity.length() >= STOP_THRESHOLD:
			parent.change_state("Stopping")
		else:
			parent.change_state("Idle")
	
	# Turning
	if root.is_turning():
		parent.change_state("Turn", {run = true})
	
	# Falling
	if root.velocity.y < 0:
		parent.change_state("Fall")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.animplayer.stop()
	root.disable_all_actions()
	super._exit(next_state)
