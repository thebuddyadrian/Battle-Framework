extends BaseState

var hit_stun_deceleration = 0.6
var hit_data: HitData


func _enter(data = {}) -> void:
	root.deceleration_enabled = false
	root.animplayer.stop()
	hit_data = data["hit_data"]
	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.WEAK:
		root.animplayer.play("Hurt")
		hit_stun_deceleration = 0.6
	root.velocity = hit_data.calculate_knockback_velocity()
	root.gravity_scale = 0.75
	if hit_data.knockback_direction.x:
		root.set_facing_direction_2d(-hit_data.knockback_direction.x)


func _step():
	
	if parent.state_time == hit_data.hit_stun:
		change_state("Idle")
		return
	root.velocity.x = move_toward(root.velocity.x, 0, hit_stun_deceleration)
	root.velocity.z = move_toward(root.velocity.z, 0, hit_stun_deceleration)
	
	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.LAUNCH:
		root.animplayer.play("Launch")
		hit_stun_deceleration = 0.3
	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.UP:
		root.animplayer.play_section_with_markers("HitUp", "loop", "loopend")
		hit_stun_deceleration = 0.3
	
	if hit_data.knockback_type == hit_data.KNOCKBACK_TYPE.LAUNCH:
		if root.is_on_floor():
			change_state("Land")
			return
		for i in root.get_slide_collision_count():
			var collision: KinematicCollision3D = root.get_slide_collision(i)
			for j in collision.get_collision_count():
				var collider = collision.get_collider(j)
				if collider is StaticBody3D:
					change_state("WallHit", {normal = collision.get_normal(j)})


func _exit(next_state: BaseState) -> void:
	root.gravity_scale = 1
	root.deceleration_enabled = true
