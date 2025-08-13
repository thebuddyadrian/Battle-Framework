extends BaseState
const WALL_HIT_EFFECT_PATH = "res://effects/wall_hit_effect.tscn"


func _enter(data = {}):
	var proj = root.spawn_scene("WallHitEffect", WALL_HIT_EFFECT_PATH, root.global_position, null, data)
	var normal: Vector3 = data["normal"]
	# Bounce off the wall using the wall's direction
	var normal_flat: Vector2 = Vector2(normal.x, normal.z)
	root.velocity.y = 12

	root.velocity.z = normal.z * 2.5
	root.velocity.x = normal.x * 2.5

	root.gravity_scale = 0.7
	root.deceleration_scale = 0.1
	root.play_sound_effect("wall_hit")


func _step():
	if root.is_on_floor():
		change_state("Down")
		return
	if root.velocity.y > 0:
		root.animplayer.play_section_with_markers("HitWall", "Bounce", "Fall")
	else:
		root.animplayer.play_section_with_markers("HitWall", "Fall", "")


func _exit(next_state):
	root.deceleration_scale = 1
	root.gravity_scale = 1
