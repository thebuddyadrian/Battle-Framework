extends BaseState


func _enter(data = {}):
	root.animplayer.play("HitFloor")


func _step():
	if parent.state_time >= 40:
		change_state("GetUp")
