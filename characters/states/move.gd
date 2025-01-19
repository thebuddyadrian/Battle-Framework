@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.moveenabled = true


func _step():
	if parent.state_time < 4:
		root.animplayer.play("MoveTransition")
	else:
		root.animplayer.play("Moving")
		
	if root.input("jump", "just_pressed"):
		parent.change_state("JumpSquat")
	if root.input("attack", "just_pressed"):
		parent.change_state("Punch1")
	if root.velocity.x == 0 and root.velocity.z == 0:
		parent.change_state("Idle")
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
