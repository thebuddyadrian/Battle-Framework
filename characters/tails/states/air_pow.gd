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
		# Spawn projectile on floor below tails
		proj.global_position = root.get_ground_position() + Vector3.UP * 0.5
			
func _exit(next_state):
	pass
