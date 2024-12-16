@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.animplayer.play("Punch1")


func _step():
	if parent.state_time == 18:
		parent.change_state("Idle")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	super._exit(next_state)
