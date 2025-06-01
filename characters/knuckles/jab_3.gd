extends BaseAttack

func _step():
	super._step()
	$"../../PlayerSprite/Misc_Effects".show()
	$"../../PlayerSprite/Misc_Effects".position = Vector3(-0.257,0.165,0.0)

# func _phase_changed():
#     if get_current_phase() == active_phase:
#         root.gravity_scale = 0.5


func _exit(next_state):
	super._exit(next_state)
	$"../../PlayerSprite/Misc_Effects".hide()
