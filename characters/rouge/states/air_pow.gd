extends BaseAttack

func _enter(data := {}):
	super._enter(data)
	root.velocity.y = -30
	root.velocity.x = clamp(root.velocity.x, -5, 5)
	root.velocity.z = clamp(root.velocity.z, -5, 5)
	root.deceleration_enabled = false
	root.play_voice_clip("sonic/sonic_air_pow")


func _step():
	super._step()
	# Bounce on floor
	if root.is_on_floor():
		root.velocity.y = 17
		root.velocity.x = attack_direction.x * 1
		root.velocity.z = attack_direction.y * 1
	
	if root.velocity.y > 0 and parent.state_time % 6 == 0:
		var data: Dictionary = {
			direction = attack_direction,
		}
		# Set the afterimage's animation frame using the current sprite frame, offset by the beginning of the current animation
		if root.animplayer.current_animation == "AirPowFwd":
			data["frame"] = root.Sprite.frame - 210
		if root.animplayer.current_animation == "AirPowDown":
			data["frame"] = root.Sprite.frame - 214
		if root.animplayer.current_animation == "AirPowUp":
			data["frame"] = root.Sprite.frame - 218
		root.spawn_scene("AirPowAfterimage", "res://effects/sonic_air_pow_afterimage.tscn", root.global_position + Vector3.DOWN * 0.2, null, data)
	
	if parent.state_time % 6 == 0 and get_current_phase() == active_phase:
		reactivate_hitbox()


func _exit(next_state):
	super._exit(next_state)
	root.deceleration_enabled = true
