@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.animplayer.play("Dash")
	root.velocity.y = root.JUMP_VELOCITY / 2
	


func _step():
	root.velocity.x = root.dirget * root.DASH_SPEED 
	if parent.state_time > 5 && root.is_on_floor():
		parent.change_state("Idle")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	super._exit(next_state)
