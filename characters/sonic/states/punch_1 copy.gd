extends BaseAttack

var startup_phase: AttackPhase
var active_phase: AttackPhase
var recovery_phase: AttackPhase


func _move_setup():
	super._move_setup()
	startup_phase = add_new_phase("startup")
	startup_phase.frames = 6
	active_phase = add_new_phase("active")
	active_phase.frames = 3
	active_phase.hitbox_active = true
	recovery_phase = add_new_phase("recovery")
	recovery_phase.frames = 15
	recovery_phase.end_phase = true
	direction_type == DIR_TYPE.TWO_DIR


func _phase_changed():
	if get_current_phase() == active_phase:
		# Do stuff when the active phase starts
		pass


func _step():
	super._step()
	if get_current_phase_name() == "recovery":
		if root.input("attack", "just_pressed"):
			change_state("Punch2")


func _enter(data = {}):
	super._enter(data)
	get_hit_data().knockback_power = 5
	get_hit_data().damage = 10
