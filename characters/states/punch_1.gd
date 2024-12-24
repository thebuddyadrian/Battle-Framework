@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.animplayer.play("Punch1")


func _step():
	if parent.state_time == 18:
		parent.change_state("Idle")
	elif parent.state_time  <= 17 && parent.state_time > 8:
		if Input.is_action_just_pressed(root.Controlset.action_attack):
			parent.change_state("Punch2")
		if Input.is_action_just_pressed(root.Controlset.action_dash):
			parent.change_state("Dash")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.animplayer.stop()
	super._exit(next_state)
