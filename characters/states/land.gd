@tool
extends BaseState

@export var frames: int = 12

func _enter(data = {}):
	root.animplayer.play("Land")
	root.velocity.x = 0


func _step():
	if parent.state_time >= frames:
		change_state("Idle")


func _exit(next_state):
	super._exit(next_state)
