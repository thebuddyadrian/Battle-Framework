extends BaseAttack

const GRND_SHOT_PROJ_PATH = "res://spawnables/Shadow_GrndTrap.tscn"
@onready var target = $"../.."
var proj_speed = 10

func _phase_changed():
	if get_current_phase() == active_phase:
		var data = {
			"direction": attack_direction,
			"velocity": Vector3(attack_direction.x * 6, 0, attack_direction.y * 6)
		}
		var proj = root.spawn_scene("GrndTrap", GRND_SHOT_PROJ_PATH, root.global_position, null, data)
		var direction = (target.position - proj.position).normalized()
		proj.velocity = direction * proj_speed
