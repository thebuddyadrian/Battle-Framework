extends BaseAttack


func _phase_changed():
	if get_current_phase_name() == "active":
		root.play_voice_clip("knuckles/knuckles_heavy")
	

func _step():
	super._step()
