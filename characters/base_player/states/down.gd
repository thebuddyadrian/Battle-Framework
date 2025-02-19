extends BaseState


func _enter(data = {}):
	root.animplayer.play("HitFloor")
	root.velocity.y = 5


func _step():
	if parent.state_time >= 25:
		root.animplayer.play("OnFloor")
	if root.is_on_floor():
		root.hurtbox.active = false
	else:
		root.hurtbox.active = true
	if parent.state_time >= 35:
		change_state("GetUp")


func _exit(next_state: BaseState):
	root.hurtbox.active = true
