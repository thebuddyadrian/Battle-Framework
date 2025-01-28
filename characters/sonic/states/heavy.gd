extends BaseAttackStandard

func _move_setup():
	animation = "Heavy"
	startup_frames = 12
	active_frames = 6
	recovery_frames = 26
	damage = 10
	knockback_power = 20
	knockback_angle = 15
	knockback_type = HitData.KNOCKBACK_TYPE.LAUNCH
	hit_stun = 60
	direction_type = DIR_TYPE.FOUR_DIR
	make_standard_attack()
	recovery_phase.end_phase = false
	var jump_phase: AttackPhase = add_new_phase("jump")
	jump_phase.frames = 18
	jump_phase.end_phase = true



func _phase_changed():
	if get_current_phase_name() == "jump":
		root.velocity.y = 5
		root.velocity.x = -root.facing_direction.x * 2
		root.velocity.z = -root.facing_direction.y * 2
