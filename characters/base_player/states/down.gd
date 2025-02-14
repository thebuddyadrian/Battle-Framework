extends BaseState


func _enter(data = {}):
	root.animplayer.play("HitFloor")
	root.hurtbox.active = false
	root.velocity.y = 5


func _step():
	if parent.state_time >= 25:
		root.animplayer.play("OnFloor")
	if parent.state_time >= 35:
		change_state("GetUp")


func _exit(next_state: BaseState):
	root.hurtbox.active = true
