extends BaseState

var dash_direction: Vector2

func _enter(data = {}):
	super._enter(data)
	# Dash in the facing direction (relative to the camera)
	dash_direction = root.facing_direction
	
	root.animplayer.play("AirAction")
	
	# Jump upwards a bit before gliding forward
	root.velocity.y = 7
	root.limit_speed = false
	# Make sure to increment the amount of air actions used, to limit the amount of times they can do it until the touch the ground
	root.air_actions_used += 1


func _step():
	if parent.state_time == 10:
		root.velocity.y = 0
	if parent.state_time > 10:
		root.animplayer.play_section_with_markers("AirAction", "loop")
		root.velocity.x = root.facing_direction.x * 8
		root.velocity.z = root.facing_direction.y * 8
		root.velocity.y = -2.5
	if root.is_on_floor():
		parent.change_state("Land")


func _exit(next_state):
	root.limit_speed = true
	root.animplayer.stop()
	super._exit(next_state)
