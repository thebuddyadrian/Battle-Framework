extends BaseSpawnable
var animation_ended: bool
func _on_spawn(data: = {}):
	var dir = Input.get_axis("right1", "left1")
	$Sprite.play("Anim")
	print(dir)
	if dir <= 0:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true


func _on_sprite_animation_finished() -> void:
	queue_free()