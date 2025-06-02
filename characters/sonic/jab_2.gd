extends BaseAttack


func _enter(data = {}):
	pass


func _step():
	$"../../PlayerSprite/Misc Effects".show()
	$"../../PlayerSprite/Misc Effects".position = Vector3(0.1,0.138,0.0)

func _exit(next_state: BaseState):
	$"../../PlayerSprite/Misc Effects".hide()
