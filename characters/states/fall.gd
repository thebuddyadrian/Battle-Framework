@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.moveenabled = true
	root.animplayer.play("Falling")


func _step():
	if root.is_on_floor():
		parent.change_state("Land")
	if Input.is_action_just_pressed(root.Controlset.action_jump) and root.air_dashes_used < root.MAX_AIR_DASHES:
		parent.change_state("AirDash")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.animplayer.stop()
	root.moveenabled = false
	super._exit(next_state)
