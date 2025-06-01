extends BaseAttack

func _step():
	super._step()
	$"../../PlayerSprite/Misc_Effects".show()
	$"../../PlayerSprite/Misc_Effects".position = Vector3(-0.07,0.193,0.0)


func _exit(next_state):
	super._exit(next_state)
	$"../../PlayerSprite/Misc_Effects".hide()
