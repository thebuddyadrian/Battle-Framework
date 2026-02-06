extends BaseState

var dash_direction: Vector2

func _enter(data = {}):
	super._enter(data)
	# Dash in the facing direction (relative to the camera)
	dash_direction = root.facing_direction
	root.spawn_scene("ShadowAirActionEffect", "res://effects/shadow_air_action_effect.tscn", root.global_position)
	root.animplayer.play("AirAction")
	root.play_sound_effect("shadow/shadow_air_action")
	# Shadow dashes in the facing their direction
	root.velocity.y = 0
	root.velocity.x = dash_direction.x * 22
	root.velocity.z = dash_direction.y * 22
	root.deceleration_scale = 0
	root.gravity_scale = 0
	root.limit_speed = false
	# Make sure to increment the amount of air actions used, to limit the amount of times they can do it until the touch the ground
	root.air_actions_used += 1


func _step():
	if parent.state_time > 6:
		root.velocity.x *= 0.1
		root.velocity.z *= 0.1
	if parent.state_time > 20:
		parent.change_state("Fall")
	if root.is_on_floor():
		parent.change_state("Land")


func _exit(next_state):
	root.deceleration_scale = 1
	root.limit_speed = true
	root.gravity_scale = 1
	root.animplayer.stop()
	super._exit(next_state)
