extends BaseState


func _enter(data = {}):
	root.animplayer.play("Stopping")
	root.acceleration_scale = 2.0
	root.set_actions_enabled(["move", "jump", "attack", "skill", "guard"], true)


func _step():
	if parent.state_time >= 12:
		change_state("Idle")
		return
	if root.is_turning():
		parent.change_state("Turn", {run = true})
	


func _exit(next_state: BaseState):
	root.disable_all_actions()
	root.acceleration_scale = 1.0
	root.deceleration_scale = 1.0
