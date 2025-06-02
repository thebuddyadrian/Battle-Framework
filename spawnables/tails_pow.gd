extends BaseSpawnable
var animation_ended: bool
func _on_spawn(data: = {}):
	$Sprite.show()
	$Sprite.play("default")
	direction = data["direction"]
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
