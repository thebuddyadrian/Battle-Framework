extends BaseState


func _enter(data = {}):
	root.animplayer.play("Turn")
	root.moveenabled = true
	root.update_facing_direction_2d()


func _step():
	if parent.state_time >= 9:
		parent.change_state("Move")


func _exit(next_state):
	root.moveenabled = false
	super._exit(next_state)
