extends BaseAttack


func _move_setup():
	var disappear_phase = add_new_phase("disappear", 1)
	disappear_phase.frames = 20

func _enter(data := {}):
	super._enter(data)
	root.effects.show()
	root.velocity = Vector3(0, 10, 0)

func _phase_changed():
	if get_current_phase_name() == "disappear":
		root.hurtbox.active = false
		root.hide()
	else:
		root.hurtbox.active = true
		root.show()

func _step():
	super._step()
	get_hit_data().hit_freeze_override = 4
	if get_current_phase_name() == "disappear" and get_current_phase_time() > 10:
		root.velocity = Vector3(0, -50, 0)
	elif get_current_phase() == active_phase:
		if parent.state_time % 2 == 0:
			reactivate_hitbox()

func _exit(next_state):
	root.show()
	root.effects.hide()
