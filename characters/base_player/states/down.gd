extends BaseState


func _enter(data = {}):
	root.animplayer.play("HitFloor")
	root.hurtbox.active = false


func _step():
	if parent.state_time >= 25:
		change_state("GetUp")


func _exit(next_state: BaseState):
	root.hurtbox.active = true
