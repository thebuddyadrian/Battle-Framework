extends BaseAttackStandard

func _move_setup():
	animation = "Upper"
	startup_frames = 3
	active_frames = 6
	recovery_frames = 18
	damage = 10
	knockback_power = 15
	knockback_angle = 90
	knockback_type = HitData.KNOCKBACK_TYPE.UP
	hit_stun = 60
	direction_type = DIR_TYPE.FOUR_DIR
	make_standard_attack()
