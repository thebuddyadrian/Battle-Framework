extends "res://characters/base_player/states/homing_dash.gd"


func _step():
	super._step()
	if parent.state_time >= 15:
		root.visible = false
		return


func _exit(next_state: BaseState):
	root.visible = true
	super._exit(next_state)
	