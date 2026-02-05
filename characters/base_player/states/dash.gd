extends BaseState
var dash_direction: Vector2
var spawned_dash_effect: bool = false
const DashEffect = "res://effects/dash_effect.tscn"

func _enter(data = {}):
	super._enter(data)
	# Dash in the facing direction (relative to the camera)
	dash_direction = root.facing_direction
	root.animplayer.play("Dash")
	root.play_sound_effect("dash")
	root.velocity.y = 9
	root.limit_speed = false
	root.set_action_enabled("attack", true)


func _step():
	var data = {"dir": root.facing_direction_2d}
	if !spawned_dash_effect:
		var proj = root.spawn_scene("DashEffect", DashEffect, root.global_position, null, data)
		proj.position = root.position
		spawned_dash_effect = true
	root.velocity.x = dash_direction.x * 12.5
	root.velocity.z = dash_direction.y * 12.5
	if parent.state_time > 5 && root.is_on_floor():
		parent.change_state("Land")


func _step_frozen():
	super._step_frozen()


func _exit(next_state):
	if next_state is BaseAttack and parent.state_time < 2:
		root.velocity.x = 0
		root.velocity.z = 0
	spawned_dash_effect = false
	root.limit_speed = true
	root.animplayer.stop()
	root.set_action_enabled("attack", false)
	super._exit(next_state)
