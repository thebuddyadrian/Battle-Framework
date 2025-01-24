extends BaseState
var dash_direction: Vector2


func _enter(data = {}):
	super._enter(data)
	# Dash in the facing direction (relative to the camera)
	dash_direction = root.facing_direction
	
	root.animplayer.play("AirDash")
	root.velocity.y = 6
	root.velocity.x = dash_direction.x * root.AIR_DASH_SPEED 
	root.velocity.z = dash_direction.y * root.AIR_DASH_SPEED 
	root.limit_speed = false
	root.air_dashes_used += 1


func _step():
	if parent.state_time > 30:
		parent.change_state("Fall")
	if root.is_on_floor():
		parent.change_state("Land")


func _exit(next_state):
	root.limit_speed = true
	root.animplayer.stop()
	super._exit(next_state)
