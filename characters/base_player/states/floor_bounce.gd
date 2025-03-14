extends BaseState

func _enter(data = {}):
	root.animplayer.play("HitFloor")
	root.velocity.y = 16
	root.gravity_scale = 0.7


func _step():
	if root.is_on_floor() and parent.state_time >= 4:
		change_state("Down")


func _exit(next_state):
	root.deceleration_scale = 1
	root.gravity_scale = 1
	root.hurtbox.active = true
