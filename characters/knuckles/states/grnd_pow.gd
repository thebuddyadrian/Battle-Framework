extends BaseAttack

const GRND_POW_EFFECT_PATH = "uid://ivfy1nbpdsfh" # knuckles_grnd_pow_effect.tscn

var effect_offset_x: float = 1.5
var effect_offset_y: float = 1.5
var effect_offset_z: float = 1.5


func _enter(data := {}):
	super._enter(data)
	root.deceleration_enabled = false
	root.velocity.x += attack_direction.x * 0.5
	root.velocity.z += attack_direction.y * 0.5
	root.play_voice_clip("knuckles/knuckles_grnd_pow")


func _phase_changed():
	if get_current_phase() == active_phase:
		root.play_sound_effect("explosion")
		root.deceleration_enabled = true
		root.velocity.x = attack_direction.x * 5
		root.velocity.z = attack_direction.y * 5
		root.deceleration_scale = 1
		var data = {"direction": attack_direction}
		var effect: BaseEffect = root.spawn_scene("GrndPowEffect", GRND_POW_EFFECT_PATH, 
				root.global_position, null, data)
		root.velocity.x = attack_direction.x * 7
		root.velocity.z = attack_direction.y * 7
		if attack_direction == Vector2.RIGHT:
			effect.position.x = root.position.x + 1.5
			effect.position.y = root.position.y
			effect.position.z = root.position.z
		elif attack_direction == Vector2.LEFT:
			effect.position.x = root.position.x - 1.5
			effect.position.y = root.position.y
			effect.position.z = root.position.z
		elif attack_direction == Vector2.UP:
			effect.position.x = root.position.x
			effect.position.y = root.position.y 
			effect.position.z = root.position.z - 1.5
		elif attack_direction == Vector2.DOWN:
			effect.position.y = root.position.y 
			effect.position.z = root.position.z + 1.5
			effect.position.x = root.position.x


func _exit(next_state):
	super._exit(next_state)
	root.deceleration_enabled = true
	root.deceleration_scale = 1
