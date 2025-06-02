extends BaseSpawnable
var animation_ended: bool
func _on_spawn(data: = {}):
	direction = data["direction"]
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
func _process(delta: float) -> void:
	if is_on_floor():
		queue_free()
