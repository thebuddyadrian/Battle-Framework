extends BaseState

var dash_direction: Vector2

func _enter(data = {}):
	super._enter(data)
	# Dash in the facing direction (relative to the camera)
	dash_direction = root.facing_direction
	
	root.animplayer.play("AirAction")
	# Sonic dashes in the facing their direction
	root.gravity_scale = 0
	# Make sure to increment the amount of air actions used, to limit the amount of times they can do it until the touch the ground
	root.air_actions_used += 1
	root.velocity.y = -3
	root.velocity.x = 5 * root.facing_direction.x
	root.velocity.z = 5 * root.facing_direction.y
	root.play_sound_effect("tails/tails_air_action")


func _step():
	if parent.state_time < 20:
		root.velocity.y += 0.3
		root.deceleration_enabled = false
	if parent.state_time > 10:
		root.set_action_enabled("move", true)
	if parent.state_time > 40:
		parent.change_state("Fall")
		return
	if root.is_on_floor():
		parent.change_state("Land")


func _exit(next_state):
	root.limit_speed = true
	root.animplayer.stop()
	root.gravity_scale = 1
	root.deceleration_enabled = true
	super._exit(next_state)
