extends BaseSpawnable


func _on_spawn(data: = {}):
	var dir = data.get("dir", 0)
	if dir <= 0:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false


func _on_sprite_animation_finished() -> void:
	queue_free()
