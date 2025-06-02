extends BaseSpawnable

func _on_spawn(data: = {}):
	$Sprite.show()
	$AnimationPlayer.play("Anim")
	direction = data["direction"]
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
	elif direction == Vector2.RIGHT:
		$Sprite.flip_h = false
func _process(delta: float) -> void:
	if is_on_floor():
		queue_free()
