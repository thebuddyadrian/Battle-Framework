@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.animplayer.play("Falling")


func _step():
	if root.is_on_floor():
		parent.change_state("Idle")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	super._exit(next_state)
