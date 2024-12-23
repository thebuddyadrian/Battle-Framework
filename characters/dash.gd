@tool
extends BaseState
var dirx
var dirz


func _enter(data = {}):
	super._enter(data)
	dirx = root.dirgetx
	dirz = root.dirgetz
	root.velocity.x = dirx * root.DASH_SPEED 
	root.velocity.z = dirz * root.DASH_SPEED
	root.animplayer.play("Dash")
	root.velocity.y = root.JUMP_VELOCITY / 2
	print_debug(dirz)


func _step():
	root.velocity.x = dirx * root.DASH_SPEED 
	root.velocity.z = dirz * root.DASH_SPEED 
	if parent.state_time > 5 && root.is_on_floor():
		parent.change_state("Idle")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	super._exit(next_state)
