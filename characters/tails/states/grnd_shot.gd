extends BaseAttack

const GRND_SHOT_PROJ_PATH = "res://spawnables/Tails_shot.tscn"


func _phase_changed():
	if get_current_phase() == active_phase:
		var data = {
			"direction": attack_direction,
			"velocity": Vector3(attack_direction.x * 6, 0, attack_direction.y * 6)
		}
		var proj = root.spawn_scene("GrndShot", GRND_SHOT_PROJ_PATH, root.global_position, null, data)
		proj.direction = attack_direction
		proj.velocity.x = attack_direction.x * 6.5
		proj.velocity.z = attack_direction.y * 6.5
		if (attack_direction == Vector2.LEFT) or (attack_direction == Vector2.RIGHT):
			proj.position.x = root.position.x + (1 * attack_direction.x)
			proj.position.y = root.position.y
		elif attack_direction == Vector2.DOWN:
			proj.position.x = root.position.x + 0.3 * root.facing_direction_2d
			proj.position.z = root.position.z + 1
			proj.position.y = root.position.y
		elif attack_direction == Vector2.UP:
			proj.position.x = root.position.x + 0.3 * root.facing_direction_2d
			proj.position.z = root.position.z - 0
			proj.position.y = root.position.y
