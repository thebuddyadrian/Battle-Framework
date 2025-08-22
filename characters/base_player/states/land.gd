extends BaseState

const DEFAULT_FRAMES: int = 12
var frames: int = 12

func _enter(data = {}):
	root.animplayer.play("Land")
	root.play_sound_effect("land")
	root.velocity.x = 0
	root.velocity.z = 0
	# Reset air skills and actions
	root.air_actions_used = 0
	root.air_skills_used = 0
	frames = data.get("frames", DEFAULT_FRAMES)


func _step():
	if parent.state_time >= frames:
		change_state("Idle")
	
	if parent.state_time >= frames / 3:
		root.set_actions_enabled(["jump"], true)
		if root.get_input_vector() != Vector2.ZERO:
			root.set_actions_enabled(["dash"], true)


func _exit(next_state):
	root.disable_all_actions()
	super._exit(next_state)
