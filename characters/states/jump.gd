@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.moveenabled = true
	root.animplayer.play("Jump")
	root.velocity.y = root.JUMP_VELOCITY


func _step():
	if root.velocity.y < 0 && !root.is_on_floor():
		parent.change_state("Fall")
	if parent.state_time > 5 and root.input("jump", "just_pressed") and root.air_dashes_used < root.MAX_AIR_DASHES:
		parent.change_state("AirDash")
	if root.is_on_floor():
		parent.change_state("Land")

func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.animplayer.stop()
	root.moveenabled = false
	super._exit(next_state)
