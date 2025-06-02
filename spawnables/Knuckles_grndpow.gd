extends BaseSpawnable

func _on_spawn(data: = {}):
	$Sprite.show()
	$AnimationPlayer.play("Anim")
	direction = data["direction"]
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
