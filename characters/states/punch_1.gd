@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.animplayer.play("Punch1")
	get_hit_data().damage = 10.0
	get_hit_data().knockback_direction.x = root.dirgetx
	get_hit_data().knockback_power = 1
	get_hit_data().knockback_angle = 0
	get_hit_data().hit_stun = 25


func _step():
	# Define active frames
	if parent.state_time == 6:
		root.hitbox.active = true
	if parent.state_time == 9:
		root.hitbox.active = false
	
	if parent.state_time == 18:
		parent.change_state("Idle")
	elif parent.state_time  <= 17 && parent.state_time > 8:
		if Input.is_action_just_pressed(root.Controlset.action_attack):
			parent.change_state("Punch2")
		if Input.is_action_just_pressed(root.Controlset.action_dash):
			parent.change_state("Dash")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.hitbox.active = false
	root.animplayer.stop()
	super._exit(next_state)
