extends BaseState

func _enter(data = {}):
	root.animplayer.play("HitFloor")
	root.velocity.y = 16
	root.gravity_scale = 0.7
	root.play_sound_effect("floor_hit")
	root.spawn_scene("FloorBounceEffect", "uid://c5rdpe83b2q8o", root.global_position)


func _step():
	if root.is_on_floor() and parent.state_time >= 4:
		change_state("Down")


func _exit(next_state):
	root.deceleration_scale = 1
	root.gravity_scale = 1
	root.hurtbox.active = true
