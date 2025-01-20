extends BaseState


func _enter(data = {}):
	root.animplayer.play("Stopping")
	root.moveenabled = true


func _step():
	if parent.state_time >= 12:
		if root.get_input_vector() != Vector2.ZERO:
			if root.is_turning():
				parent.change_state("Turn")
				return
			parent.change_state("Move")
			return
		change_state("Idle")
		return
	


func _exit(next_state: BaseState):
	root.moveenabled = false
