extends BaseAttack

const GRND_SHOT_PROJ_PATH = "res://spawnables/Sonic_GrndShot.tscn"


func _phase_changed():
	if get_current_phase() == active_phase:
		var data = {
			"direction": attack_direction,
			"velocity": Vector3(attack_direction.x * 6, 0, attack_direction.y * 6)
		}
		var proj = root.spawn_scene("GrndShot", GRND_SHOT_PROJ_PATH, root.global_position, null, data)
		proj.direction = attack_direction
		proj.velocity.x = attack_direction.x * 10
		proj.velocity.z = attack_direction.y * 10