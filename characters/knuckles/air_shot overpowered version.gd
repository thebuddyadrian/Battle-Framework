extends BaseAttack
const GRND_SHOT_PROJ_PATH = "res://spawnables/knuckles_air_shot.tscn"
func _enter(data := {}):
	super._enter(data)
	root.velocity = Vector3(0,0,0)


func _step():
	super._step()
	root.velocity.y = 0.5
	if get_current_phase() == active_phase:
		for i in range(3):
			var data = {
				"direction": attack_direction,
				"velocity": Vector3(attack_direction.x * 6, 0, attack_direction.y * 6)
			}
			var proj = root.spawn_scene("GrndShot", GRND_SHOT_PROJ_PATH, root.global_position, null, data)
			proj.direction = attack_direction
			if (attack_direction == Vector2.RIGHT) or (attack_direction == Vector2.LEFT):
				proj.velocity.x = root.facing_direction.x * 5 + randf_range(-5, 5)
				proj.velocity.y =  -20 
				proj.position.y =  root.position.y + 5
				proj.position.x =  root.position.x + 2 * root.facing_direction.x + randf_range(-5, 5)
				proj.position.z = root.position.z
			elif (attack_direction == Vector2.UP):
				proj.velocity.z =  -5 + randf_range(-4, 4)
				proj.velocity.y =  -20
				proj.position.y =  root.position.y + 5
				proj.position.x =  root.position.x
				proj.position.z =  root.position.z - 2 + randf_range(-1, 1)


func _exit(next_state):
	root.deceleration_enabled = true
