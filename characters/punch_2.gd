@tool
extends BaseState


func _enter(data = {}):
	super._enter(data)
	root.animplayer.play("kick1")
	get_hit_data().damage = 10.0
	get_hit_data().knockback_direction.x = sign(root.attack_direction)
	get_hit_data().knockback_power = 1
	get_hit_data().knockback_angle = 0
	get_hit_data().hit_stun = 25


func _step():
	if parent.state_time == 2:
		root.hitbox.active = true
	if parent.state_time == 4:
		root.hitbox.active = false
		
	if parent.state_time == 18:
		parent.change_state("Idle")
	elif parent.state_time  <= 17 && parent.state_time > 8:
		if root.input("attack", "just_pressed"):
			parent.change_state("Punch3")
		if root.input("dash", "just_pressed"):
			parent.change_state("Dash")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	root.animplayer.stop()
	super._exit(next_state)
