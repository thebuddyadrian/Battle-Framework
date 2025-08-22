extends BaseAttack
const GRND_POW_PROJ_PATH = "res://spawnables/tails_pow.tscn"
func _enter(data := {}):
	super._enter(data)
	root.velocity.y = 12

func _step():
	super._step()
	# if get_current_phase() == startup_phase:
	# 	root.velocity = Vector3(0, 0, 0)
	# elif get_current_phase() == active_phase:
	# 	root.velocity = Vector3(0, 0, 0)
	# elif get_current_phase() == recovery_phase:
	# 	root.velocity.y = lerp(root.velocity.y, -5.0, 0.3)
	pass

func _phase_changed():
	if get_current_phase() == active_phase:
		var data = {
			"direction": attack_direction,
			"velocity": Vector3(attack_direction.x * 6, 0, attack_direction.y * 6)
		}
		var proj = root.spawn_scene("GrndPow", GRND_POW_PROJ_PATH, root.global_position, null, data)
		proj.direction = attack_direction
		proj.velocity = Vector3(0.0,0.0,0.0)
		if(attack_direction == Vector2.RIGHT):
			proj.position.z =  root.position.z
			proj.position.y =  1
			proj.position.x =  root.position.x
		elif (attack_direction == Vector2.LEFT):
			proj.position.z =  root.position.z
			proj.position.y =  1
			proj.position.x =  root.position.x
		elif (attack_direction == Vector2.UP):
			proj.position.z =  root.position.z
			proj.position.y =  1
			proj.position.x =  root.position.x
		elif (attack_direction == Vector2.DOWN):
			proj.position.z =  root.position.z
			proj.position.y =  1
			proj.position.x =  root.position.x
			
			
func _exit(next_state):
	pass
