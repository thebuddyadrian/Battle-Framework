extends BaseState
var dash_direction: Vector2


func _enter(data = {}):
	super._enter(data)
	# Dash in the facing direction (relative to the camera)
	dash_direction = root.facing_direction
	root.animplayer.play("Dash")
	root.play_sound_effect("dash")
	root.limit_speed = false
	root.set_action_enabled("attack", true)


func _step():
	root.velocity.x = dash_direction.x * root.DASH_SPEED 
	root.velocity.z = dash_direction.y * root.DASH_SPEED 
	if parent.state_time > 25 :
		parent.change_state("Idle")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.limit_speed = true
	root.animplayer.stop()
	root.set_action_enabled("attack", false)
	super._exit(next_state)
