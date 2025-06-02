extends BaseAttack
const GRND_SHOT_PROJ_PATH = "res://spawnables/Tails_shot.tscn"
func _enter(data := {}):
	super._enter(data)
	root.velocity = Vector3(0,0,0)


func _step():
	super._step()
	root.velocity.y = 0.5


func _phase_changed():
	if get_current_phase() == active_phase:
		var data = {
			"direction": attack_direction,
			"velocity": Vector3(attack_direction.x * 6, 0, attack_direction.y * 6)
		}
		var proj = root.spawn_scene("GrndShot", GRND_SHOT_PROJ_PATH, root.global_position, null, data)
		proj.direction = attack_direction
		proj.velocity.y = -7
		if (attack_direction == Vector2.LEFT) or (attack_direction == Vector2.RIGHT):
			proj.velocity.x = root.facing_direction.x * 7
			proj.position.y =  root.position.y
			proj.position.x =  root.position.x
		elif attack_direction == Vector2.DOWN or attack_direction == Vector2.UP:
			proj.velocity.x = 0
			proj.velocity.z = root.facing_direction.y * 11
			

func _exit(next_state):
	root.deceleration_enabled = true
