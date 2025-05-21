extends BaseSpawnable

func _on_spawn(data: = {}):
	direction = data["direction"]
	$Sprite.animation = "Side"
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
