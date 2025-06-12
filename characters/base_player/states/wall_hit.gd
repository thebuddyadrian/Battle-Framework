extends BaseState
const WALL_HIT_EFFECT_PATH = "res://spawnables/wall_hit_effect.tscn"

const WALL_BOUNCE_DECAY = 0.75
const MIN_WALL_BOUNCES = 0 # Wall bounces has to be at least this amount before decay kicks in

func _enter(data = {}):
	var proj = root.spawn_scene("WallHitEffect", WALL_HIT_EFFECT_PATH, root.global_position, null, data)
	var normal: Vector3 = data["normal"]
	# Bounce off the wall using the wall's direction
	var normal_flat: Vector2 = Vector2(normal.x, normal.z)
	root.velocity.y = 12

	var wall_bounces_calculated = root.wall_bounces - MIN_WALL_BOUNCES

	root.velocity.z = normal.z * 2.5
	root.velocity.x = normal.x * 2.5

	if wall_bounces_calculated > 0:
		root.hurtbox.active = false
		root.velocity /= 1 + wall_bounces_calculated * WALL_BOUNCE_DECAY

	root.gravity_scale = 0.7
	root.deceleration_scale = 0.1
	root.wall_bounces += 1
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
