extends BaseSpawnable

var direction: Vector2 = Vector2.RIGHT

## Runs during the physics process. Has delta time as a var. Use this instead of overriding physics process.
func _do_behavior(delta):
	if direction == Vector2.UP:
		$Sprite.animation = "Up"
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
	if direction == Vector2.DOWN:
		$Sprite.animation = "Down"