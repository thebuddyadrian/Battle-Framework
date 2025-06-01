extends BaseAttack

const GRND_SHOT_PROJ_PATH = "res://spawnables/knuckles_GrndShot.tscn"


func _phase_changed():
	if get_current_phase() == active_phase:
		var data = {
			"direction": attack_direction,
			"velocity": Vector3(attack_direction.x * 6, 0, attack_direction.y * 6)
		}
		var proj = root.spawn_scene("GrndShot", GRND_SHOT_PROJ_PATH, root.global_position, null, data)
		proj.direction = attack_direction
		if attack_direction == Vector2.RIGHT:
			proj.position.y = root.position.y + 1
			proj.position.x = root.position.x + 1
		if attack_direction == Vector2.LEFT:
			proj.position.y = root.position.y - 1
			proj.position.x = root.position.x - 1
		proj.position.z = root.position.z 
		proj.velocity.x = attack_direction.x * 10
		proj.velocity.z = attack_direction.y * 10
func _process(delta: float) -> void:
	if root.facing_direction == Vector2.RIGHT:
		$"../../PlayerSprite/Effects".flip_h = false
	elif root.facing_direction == Vector2.LEFT:
		$"../../PlayerSprite/Effects".flip_h = true
func _step():
	super._step()
	print(root.facing_direction)
	print($"../../PlayerSprite/Effects".flip_h)
	if get_current_phase() == startup_phase:
		$"../../PlayerSprite/Effects".show()
		await get_tree().create_timer(0.18).timeout
		$"../../PlayerSprite/Effects".position = Vector3(-0.258, -0.11, 0.0)
		await get_tree().create_timer(0.06).timeout
		$"../../PlayerSprite/Effects".position = Vector3(-0.317, -0.011, 0.0)
		await get_tree().create_timer(0.06).timeout
		$"../../PlayerSprite/Effects".position = Vector3(-0.197, 0.329, 0.0)
		await get_tree().create_timer(0.06).timeout
		$"../../PlayerSprite/Effects".position = Vector3(0.013, 0.417, 0.0)
		await get_tree().create_timer(0.06).timeout
		$"../../PlayerSprite/Effects".position = Vector3(0.193, 0.388, 0.0)#
		await get_tree().create_timer(0.06).timeout
		$"../../PlayerSprite/Effects".position = Vector3(-0.017, 0.398, 0.0)
		await get_tree().create_timer(0.06).timeout
		$"../../PlayerSprite/Effects".position = Vector3(-0.177, 0.368, 0.0)
		await get_tree().create_timer(0.06).timeout
		$"../../PlayerSprite/Effects".position = Vector3(0.0, 0.0, 0.0)
