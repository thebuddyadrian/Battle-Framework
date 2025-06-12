extends BaseAttack
var has_teleported:bool = false
func _enter(data := {}):
	super._enter(data)
func _step():
	super._step()
	$"../../PlayerSprite/Effects".show()
	if get_current_phase() == startup_phase:
		root.velocity = Vector3(0, 0, 0)
	elif get_current_phase() == startup_phase:
		root.velocity = Vector3(0, 0, 0)
	elif get_current_phase() == active_phase:
		if parent.state_time % 10 == 0:
			reactivate_hitbox()
		if $"../../PlayerSprite".flip_h and !has_teleported:
			root.velocity.x = -30
			has_teleported = true
		if !$"../../PlayerSprite".flip_h and !has_teleported:
			root.velocity.x = 30
			has_teleported = true
		if has_teleported:
			await get_tree().create_timer(0.2).timeout
			root.velocity.x = 0
	elif get_current_phase() == recovery_phase:
		has_teleported = false
func _exit(next_state):
	pass
