extends BaseAttack
var air_attack_jumped: bool = false

func _phase_changed():
	if get_current_phase() == startup_phase:
		root.velocity.y = 15
		if $"../../PlayerSprite".flip_h:
			root.velocity.x = -4
		elif !$"../../PlayerSprite".flip_h:
			root.velocity.x = 4
	elif get_current_phase() == active_phase:
		print("active")
		root.velocity.y = -20
		if $"../../PlayerSprite".flip_h:
			root.velocity.x = -14
		elif !$"../../PlayerSprite".flip_h:
			root.velocity.x = 14
			
