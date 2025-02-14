extends BaseState

func _enter(data = {}):
	#root.velocity.x = clamp(root.velocity.x, -20, 20)
	#root.velocity.z = clamp(root.velocity.z, -20, 20)
	root.velocity.y = 15
	root.animplayer.play("HomingDash")
	root.gravity_scale = 0
	root.set_action_enabled("attack", true)


func _step():
	if parent.state_time >= 35:
		parent.change_state("Fall")
		return
	
	var opponent_position: Vector3 = root.last_hit_player.global_position
	var opponent_is_behind: bool = false
	
	if root.facing_direction.x > 0 and opponent_position.x < root.global_position.x:
		opponent_is_behind = true
	if root.facing_direction.x < 0 and opponent_position.x > root.global_position.x:
		opponent_is_behind = true
	if root.facing_direction.y < 0 and opponent_position.z > root.global_position.z:
		opponent_is_behind = true
	if root.facing_direction.y > 0 and opponent_position.z < root.global_position.z:
		opponent_is_behind = true
	
	if parent.state_time <= 25 and !opponent_is_behind:
		var distance_x = abs(root.global_position.x - root.last_hit_player.global_position.x)
		var distance_z = abs(root.global_position.z - root.last_hit_player.global_position.z)
		root.velocity.x = distance_x * 3.0 * root.facing_direction.x
		root.velocity.z = distance_z * 3.0 * root.facing_direction.y
	else:
		root.velocity.x *= 0.95
		root.velocity.y *= 0.95
	root.velocity.y *= 0.93


func _exit(next_state: BaseState):
	root.velocity.x = clamp(root.velocity.x, -root.SPEED, root.SPEED)
	root.velocity.z = clamp(root.velocity.z, -root.SPEED, root.SPEED)
	root.gravity_scale = 1
	root.set_action_enabled("attack", false)
