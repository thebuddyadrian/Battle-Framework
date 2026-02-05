extends BaseState

var hit_stun_deceleration = 0.6
var hit_data: HitData
const LIGHT_HIT_EFFECT_PATH = "res://effects/light_hit_effect.tscn"
const HEAVY_HIT_EFFECT_PATH = "res://effects/heavy_hit_effect.tscn"


func _enter(data = {}) -> void:
	root.deceleration_enabled = false
	root.animplayer.stop()
	hit_data = data["hit_data"]

	# Play initial animation frame
	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.LAUNCH:
		root.animplayer.play("Launch")
	elif hit_data.knockback_type == HitData.KNOCKBACK_TYPE.UP:
		root.animplayer.play("HitUp")
	else:
		root.animplayer.play("Hurt")

	# When the player is at 0 health, force a knockdown
	if root.current_hp <= 0:
		hit_data.knockback_type = HitData.KNOCKBACK_TYPE.KNOCKDOWN

	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.WEAK:
		var spawn_position: Vector3 = root.global_position + Vector3(0, 1, 0)
		var effect = root.spawn_scene("LightHitEffect", LIGHT_HIT_EFFECT_PATH, spawn_position, null)
		hit_stun_deceleration = 0.6
	elif hit_data.knockback_type == HitData.KNOCKBACK_TYPE.LAUNCH:
		root.spawn_scene("HeavyHitEffect", HEAVY_HIT_EFFECT_PATH, root.global_position + Vector3.UP * 1, null, data)
		hit_stun_deceleration = 0.6
	else:
		var spawn_position: Vector3 = root.global_position + Vector3(0, 1, 0)
		var effect = root.spawn_scene("LightHitEffect", LIGHT_HIT_EFFECT_PATH, spawn_position, null)
		hit_stun_deceleration = 0.3
	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.KNOCKDOWN:
		root.animplayer.play("Knockdown")
	root.velocity = hit_data.calculate_knockback_velocity()
	root.gravity_scale = 0.7
	if hit_data.knockback_direction.x:
		root.set_facing_direction_2d(-hit_data.knockback_direction.x)


func _step():
	var data = {}
	if parent.state_time == hit_data.hit_stun and hit_data.knockback_type != HitData.KNOCKBACK_TYPE.KNOCKDOWN:
		change_state("Idle")
		return
	root.velocity.x = move_toward(root.velocity.x, 0, hit_stun_deceleration)
	root.velocity.z = move_toward(root.velocity.z, 0, hit_stun_deceleration)

	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.LAUNCH:
		root.animplayer.play("Launch")
		if root.is_on_floor():
			change_state("Land")
			return
		for i in root.get_slide_collision_count():
			var collision: KinematicCollision3D = root.get_slide_collision(i)
			for j in collision.get_collision_count():
				var collider = collision.get_collider(j)
				if collider is StaticBody3D:
					var normal = collision.get_normal()
					var normal_flat = Vector2(normal.x, normal.z)
					var teched: bool = false
					if abs(normal_flat.x) > abs(normal_flat.y):
						if sign(root.get_input_vector().x) == sign(normal_flat.x) and root.get_input_vector().x != 0:
							teched = true
					else:
						if sign(root.get_input_vector().y) == sign(normal_flat.y) and root.get_input_vector().y != 0:
							teched = true
					if teched:
						change_state("WallTech", {normal = collision.get_normal(j)})
						return
					change_state("WallBounce", {normal = collision.get_normal(j)})
					return
	
	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.UP:
		root.animplayer.play_section_with_markers("HitUp", "loop", "loopend")
		
	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.DOWN:
		if root.is_on_floor():
			change_state("FloorBounce")
			return
	
	if hit_data.knockback_type == HitData.KNOCKBACK_TYPE.KNOCKDOWN:
		if root.is_on_floor():
			change_state("Down")
			return


func _exit(next_state: BaseState) -> void:
	root.gravity_scale = 1
	root.deceleration_enabled = true
