extends BaseState

const HIT_STUN_DECELERATION = 0.5


var hit_data: HitData


func _enter(data = {}) -> void:
	root.moveenabled = false
	root.deceleration_enabled = false
	root.animplayer.stop()
	root.animplayer.play("Hurt")
	hit_data = data["hit_data"]
	print("Hurt.gd: %s" % hit_data.knockback_direction)
	root.velocity = hit_data.calculate_knockback_velocity()


func _step():
	if parent.state_time == hit_data.hit_stun:
		change_state("Idle")
	root.velocity.x = move_toward(root.velocity.x, 0, HIT_STUN_DECELERATION)
	root.velocity.z = move_toward(root.velocity.z, 0, HIT_STUN_DECELERATION)


func _exit(next_state: BaseState) -> void:
	root.moveenabled = true
	root.deceleration_enabled = true
