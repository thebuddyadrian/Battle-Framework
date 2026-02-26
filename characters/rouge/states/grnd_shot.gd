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
		root.velocity.y = 12
		root.velocity.x = -root.facing_direction.x * 7
		root.velocity.z = -root.facing_direction.y * 7


func _step():
	super._step()
	if parent.state_time == 16:
		root.play_voice_clip("sonic/sonic_grnd_shot")
	if parent.state_time == 8:
		apply_hit_data()
		root.hitbox.active = true
	if parent.state_time == 16:
		root.hitbox.active = false
	if get_current_phase() == active_phase or get_current_phase() == recovery_phase:
		if root.is_on_floor() and root.velocity.y < 0:
			parent.change_state("Land")