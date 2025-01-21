extends BaseState
class_name GroundMovementState


func _enter(data = {}):
	root.set_actions_enabled(["move", "jump", "attack", "skill", "guard"], true)


func _step():
	pass


func _exit(_next_state):
	root.disable_all_actions()
