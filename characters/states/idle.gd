@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.animplayer.play("Idle")


func _step():
	super._step()
	if Input.is_action_pressed(root.Controlset.action_jump):
		parent.change_state("Jump")
	if Input.is_action_pressed(root.Controlset.action_attack):
		parent.change_state("Punch1")
	if Input.is_action_just_pressed(root.Controlset.action_dash):
		parent.change_state("Dash")
	if root.velocity.x != 0 or root.velocity.z != 0:
		parent.change_state("Move")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	super._exit(next_state)
