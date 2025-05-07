extends BaseState

var dash_direction: Vector2

func _enter(data = {}):
	super._enter(data)
	# Dash in the facing direction (relative to the camera)
	dash_direction = root.facing_direction
	
	root.animplayer.play("AirAction")
	root.play_sound_effect("sonic_ballet")
	# Sonic dashes in the facing their direction
	root.velocity.y = 6
	root.velocity.x = dash_direction.x * 15
	root.velocity.z = dash_direction.y * 15
	root.limit_speed = false
	# Make sure to increment the amount of air actions used, to limit the amount of times they can do it until the touch the ground
	root.air_actions_used += 1


func _step():
	if parent.state_time > 30:
		parent.change_state("Fall")
	if root.is_on_floor():
		parent.change_state("Land")


func _exit(next_state):
	root.limit_speed = true
	root.animplayer.stop()
	super._exit(next_state)
