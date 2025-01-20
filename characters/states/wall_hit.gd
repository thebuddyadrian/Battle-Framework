extends BaseState

func _enter(data = {}):
	var normal: Vector3 = data["normal"]
	var normal_flat: Vector2 = Vector2(normal.x, normal.z)
	root.velocity.y = 10
	root.velocity.z = normal.z * 2.5
	root.velocity.x = normal.x * 2.5
	root.gravity_scale = 0.7
	root.animplayer.play("HitWall")
	root.deceleration_scale = 0.1


func _step():
	if root.is_on_floor():
		change_state("Down")


func _exit(next_state):
	root.deceleration_scale = 1
	root.gravity_scale = 1
