extends BaseAttack


# Heavy attack needs some more phases, so a custom script is needed
func _move_setup():
	recovery_phase.end_phase = false
	var jump_phase: AttackPhase = add_new_phase("jump")
	jump_phase.frames = 18
	jump_phase.end_phase = true


func _phase_changed():
	if get_current_phase_name() == "active":
		root.play_voice_clip("knuckles/knuckles_heavy")
	if get_current_phase_name() == "jump":
		root.velocity.y = 5
		root.velocity.x = -root.facing_direction.x * 2
		root.velocity.z = -root.facing_direction.y * 2
	


func _step():
	super._step()
