@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.animplayer.play("Jump")
	root.velocity.y = root.JUMP_VELOCITY


func _step():
	if root.velocity.y < 0:
		parent.change_state("Fall")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	super._exit(next_state)
