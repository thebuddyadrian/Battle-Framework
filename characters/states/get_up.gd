extends BaseState


func _enter(data = {}):
	root.animplayer.play("GetUp")


func _step():
	if parent.state_time >= 40:
		change_state("Idle")
