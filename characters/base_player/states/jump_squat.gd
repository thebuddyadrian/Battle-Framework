extends BaseState

@export var frames: int = 4

func _enter(data = {}):
	root.animplayer.play("JumpSquat")


func _step():
	if parent.state_time >= frames:
		change_state("Jump")


func _exit(next_state):
	super._exit(next_state)
