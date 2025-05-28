extends BaseSpawnable

func _on_spawn(data: = {}):
	direction = data["direction"]
	print(direction)
	if direction == Vector2.UP:
		$Sprite.animation = "Up"
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
	if direction == Vector2.DOWN:
		$Sprite.animation = "Down"
