extends BaseAttack
const GRND_POW_PROJ_PATH = "res://spawnables/Knuckles_GrndPow.tscn"
var proj_offset_x: float = 1.5
var proj_offset_y: float = 1.5
var proj_offset_z: float = 1.5
var explosion: bool = false
var proj
func _enter(data := {}):
	super._enter(data)


func _step():
	super._step()
	var data = {
			"direction": attack_direction,
		}
	if get_current_phase() == startup_phase:
		root.velocity.x = lerp(0.0, attack_direction.x * 7, 0.5)
		root.velocity.z = lerp(0.0, attack_direction.y * 7, 0.5)
	elif get_current_phase() == active_phase:
		if !explosion:
			proj = root.spawn_scene("GrndShot", GRND_POW_PROJ_PATH, root.global_position, null, data)
			explosion = true
		root.velocity.x = attack_direction.x * 7
		root.velocity.z = attack_direction.y * 7
		if is_instance_valid(proj):
			if attack_direction == Vector2.RIGHT:
				proj.position.x = root.position.x + proj_offset_x
				proj.position.y = root.position.y
				proj.position.z = root.position.z
			elif attack_direction == Vector2.LEFT:
				proj.position.x = root.position.x - proj_offset_x
				proj.position.y = root.position.y
				proj.position.z = root.position.z
			elif attack_direction == Vector2.UP:
				proj.position.x = root.position.x
				proj.position.y = root.position.y 
				proj.position.z = root.position.z - proj_offset_z
			elif attack_direction == Vector2.DOWN:
				proj.position.y = root.position.y 
				proj.position.z = root.position.z + proj_offset_z
				proj.position.x = root.position.x
	elif get_current_phase() == recovery_phase:
		
		root.velocity.x = lerp(attack_direction.x * 7, 0.0, 0.6)
		root.velocity.z = lerp(attack_direction.y * 7, 0.0, 0.6)
	
func _phase_changed():
	if get_current_phase() == recovery_phase and proj:
		explosion = false
		proj.queue_free()

func _exit(next_state):
	super._exit(next_state)
