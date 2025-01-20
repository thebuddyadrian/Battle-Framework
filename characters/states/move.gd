extends BaseState

const STOP_THRESHOLD = 6.0

var turn: bool = false

func _enter(data = {}):
	super._enter(data)
	root.moveenabled = true


func _step():
	if parent.state_time < 4:
		root.animplayer.play("MoveTransition")
	else:
		root.animplayer.play("Moving")
	
	# Jumping
	if root.input("jump", "just_pressed"):
		parent.change_state("JumpSquat")
	
	if root.input("attack", "just_pressed"):
		if root.get_input_vector() == Vector2.ZERO:
			parent.change_state("Punch1")
		else:
			parent.change_state("Heavy")
	
	# Stopping
	if root.get_input_vector() == Vector2.ZERO:
		if root.velocity.length() >= STOP_THRESHOLD:
			parent.change_state("Stopping")
		else:
			parent.change_state("Idle")
	
	# Turning
	if root.is_turning():
		parent.change_state("Turn")
	
	if root.input("dash", "just_pressed"):
		parent.change_state("Dash")
	if root.velocity.y < 0:
		parent.change_state("Fall")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.animplayer.stop()
	root.moveenabled = false
	super._exit(next_state)
