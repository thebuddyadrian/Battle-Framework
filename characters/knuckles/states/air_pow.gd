extends BaseAttack
var has_jumped: bool = false
func _enter(data := {}):
	super._enter(data)
	root.velocity.y = -24
	root.velocity.x = clamp(root.velocity.x, -5, 5)
	root.velocity.z = clamp(root.velocity.z, -5, 5)
	root.deceleration_enabled = false


func _step():
	super._step()
	$"../../PlayerSprite/Effects".show()
	root.velocity.x = 0
	root.velocity.z = 0
	if root.is_on_floor() and get_current_phase() == active_phase and !has_jumped:
		root.velocity.y = 0
		has_jumped = true
		await get_tree().create_timer(0.75).timeout
		root.velocity.y = 25
		has_jumped = false
	
	if parent.state_time % 10 == 0 and get_current_phase() == active_phase:
		reactivate_hitbox()


func _exit(next_state):
	root.deceleration_enabled = true
