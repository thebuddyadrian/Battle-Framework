extends BaseState

func _enter(data = {}):
	root.animplayer.play("Blocked")
	# Stagger backwards, in the opposite direction the player is facing
	root.velocity.x = -root.facing_direction.x * 5
	root.velocity.z = -root.facing_direction.y * 5


func _step():
	if parent.state_time >= 48:
		change_state("Idle")


func _exit(next_state: BaseState):
	pass
