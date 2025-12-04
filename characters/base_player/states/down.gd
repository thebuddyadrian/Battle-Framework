extends BaseState


func _enter(data = {}):
	root.animplayer.play("HitFloor")
	root.velocity.y = 3

	# When the 
	if root.current_hp <= 0:
		root.play_voice_clip("%s/%s_ko" % [root.char_name, root.char_name])


func _step():
	if parent.state_time >= 25:
		root.animplayer.play("OnFloor")
	
	# Allow player to follow up with an attack right when they hit the floor
	if root.is_on_floor():
		root.hurtbox.active = false
		if root.invincibility_frames == 0:
			root.invincibility_frames = 75
	# When the player is fully down, they can no longer be hit
	else:
		root.hurtbox.active = true

	
	if parent.state_time >= 35:
		# When a player no longer has HP, they will respawn
		if root.current_hp <= 0:
			change_state("Respawn")
		else:
			change_state("GetUp")


func _exit(next_state: BaseState):
	root.hurtbox.active = true
