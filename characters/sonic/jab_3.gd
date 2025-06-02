extends BaseAttack


func _enter(data = {}):
	pass


func _step():
	$"../../PlayerSprite/Misc_Effects".show()
	$"../../PlayerSprite/Misc_Effects".position = Vector3(0.048,0.19,0.0)

func _exit(next_state: BaseState):
	$"../../PlayerSprite/Misc_Effects".hide()
