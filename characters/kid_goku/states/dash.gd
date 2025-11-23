extends BaseState
var dash_direction: Vector2
var spawned_dash_effect: bool = false
const GRND_SHOT_PROJ_PATH = "res://spawnables/dash_effect.tscn"
func _enter(data = {}):
	super._enter(data)
	# Dash in the facing direction (relative to the camera)
	dash_direction = root.facing_direction
	root.animplayer.play("Dash")
	root.play_sound_effect("dash")
	root.velocity.y = 0
	root.limit_speed = false
	root.set_action_enabled("attack", true)


func _step():
	var data = {"dir": root.facing_direction_2d}
	if !spawned_dash_effect:
		var proj = root.spawn_scene("GrndShot", GRND_SHOT_PROJ_PATH, root.global_position, null, data)
		proj.position = root.position
		spawned_dash_effect = true
	root.velocity.x = dash_direction.x * 16
	root.velocity.z = dash_direction.y * 16
	if parent.state_time > 20:
		parent.change_state("Idle")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	spawned_dash_effect = false
	root.limit_speed = true
	root.animplayer.stop()
	root.set_action_enabled("attack", false)
	super._exit(next_state)
