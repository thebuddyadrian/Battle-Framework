extends BaseState


func _enter(data = {}):
	root.animplayer.play("Stopping")
	root.moveenabled = true
	# The player can turn around much faster
	root.acceleration_scale = 2.0
	root.deceleration_scale = 1.5


func _step():
	if parent.state_time >= 12:
		change_state("Idle")
		return
	


func _exit(next_state: BaseState):
	root.acceleration_scale = 1.0
	root.deceleration_scale = 1.0
	root.moveenabled = false
