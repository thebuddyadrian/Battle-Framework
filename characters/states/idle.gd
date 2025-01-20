extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.moveenabled = true
	root.animplayer.play("Idle")


func _step():
	super._step()
	if root.input("jump", "just_pressed"):
		parent.change_state("JumpSquat")
	elif root.input("attack", "just_pressed"):
		parent.change_state("Punch1")
	elif root.input("dash", "just_pressed"):
		parent.change_state("Dash")
	elif root.get_input_vector() != Vector2.ZERO:
		if root.is_turning():
			parent.change_state("Turn")
		else:
			parent.change_state("Move")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.moveenabled = false
	root.animplayer.stop()
	super._exit(next_state)
