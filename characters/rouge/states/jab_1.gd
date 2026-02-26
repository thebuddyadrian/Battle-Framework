extends BaseAttack
#Trying to implement the hit effects, but it bugs the game

func _step():
	
	#$"../../PlayerSprite/Misc Effects".show()
	#$"../../PlayerSprite/Misc Effects".position = Vector3(0.169,0.11,0.0)
	pass

func _exit(next_state: BaseState):
	pass
	#$"../../PlayerSprite/Misc Effects".hide()
