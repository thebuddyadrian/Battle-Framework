extends BaseAttack

const GRND_SHOT_PROJ_PATH = "res://spawnables/Shadow_GrndShot.tscn"



func _enter(data: Dictionary = {}):
	super._enter(data)
	root.play_voice_clip("shadow/shadow_grnd_shot")


func _phase_changed():
	if get_current_phase() == active_phase:
		var data = {
			"direction": attack_direction
		}
		var proj = root.spawn_scene("GrndShot", GRND_SHOT_PROJ_PATH, root.global_position, null, data)
		proj.direction = attack_direction
		# Spawn projectile in front of Shadow using the attack direction
		var proj_spawn_offset: Vector3 = Vector3(attack_direction.x * 1.25, 0, attack_direction.y * 1.25)		
		proj.global_position = root.global_position + proj_spawn_offset
		
		# Check for collision in front of shadow, moving the raycast upward to check for any platforms
		var ground_pos_y_in_front: float = root.get_ground_position(proj_spawn_offset + Vector3.UP * 5).y
		# If there's a platform in front of shadow (ground position is higher than original spawn point), move the projectile upwards
		if ground_pos_y_in_front > proj.global_position.y + 1:
			proj.global_position.y = ground_pos_y_in_front + 0.5
