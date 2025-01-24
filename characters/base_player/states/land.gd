extends BaseState

const DEFAULT_FRAMES: int = 12
var frames: int = 12

func _enter(data = {}):
	root.animplayer.play("Land")
	root.velocity.x = 0
	root.velocity.z = 0
	root.air_dashes_used = 0
	frames = data.get("frames", DEFAULT_FRAMES)


func _step():
	if parent.state_time >= frames:
		change_state("Idle")


func _exit(next_state):
	super._exit(next_state)
