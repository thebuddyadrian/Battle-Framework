extends BaseState

func _enter(data = {}):
	root.animplayer.play("Blocked")
	# Stagger backwards, in the opposite direction the player is facing
	root.velocity.x = -root.facing_direction.x * 5
	root.velocity.z = -root.facing_direction.y * 5


func _step():
	$"../../PlayerSprite/Misc Effects".show()
	$"../../PlayerSprite/Misc Effects".position = Vector3(0.03, 0.128, 0.0)
	if parent.state_time >= 48:
		change_state("Idle")


func _exit(next_state: BaseState):
	$"../../PlayerSprite/Misc Effects".hide()
