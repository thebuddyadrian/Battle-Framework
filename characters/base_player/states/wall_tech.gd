extends BaseState
const WALL_HIT_EFFECT_PATH = "res://spawnables/wall_hit_effect.tscn"

const WALL_BOUNCE_DECAY = 0.75
const MIN_WALL_BOUNCES = 0 # Wall bounces has to be at least this amount before decay kicks in
var normal_flat: Vector2

func _enter(data = {}):
	var normal: Vector3 = data["normal"]
	# Bounce off the wall using the wall's direction
	normal_flat = Vector2(normal.x, normal.z)
	root.match_facing_direction_to_movement()
	root.update_facing_direction_2d()

	root.animplayer.play("WallTech")
	root.gravity_scale = 0
	root.velocity = Vector3.ZERO


func _step():
	if parent.state_time == 6:
		parent.change_state("HomingDash", {"opponent": root.last_player_hit_by})
	if parent.state_time >= 35:
		parent.change_state("Fall")
		return
	



func _exit(next_state):
	root.deceleration_scale = 1
	root.gravity_scale = 1
