extends BaseState


func _enter(data = {}):
	root.animplayer.play("GetUp")
	root.hurtbox.active = false


func _step():
	if parent.state_time >= 40:
		change_state("Idle")


func _exit(next_state: BaseState):
	root.hurtbox.active = true
