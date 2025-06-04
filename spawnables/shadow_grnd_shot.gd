extends BaseSpawnable

func _on_spawn(data: = {}):
	direction = data["direction"]
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
		
