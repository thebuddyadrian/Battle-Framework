extends Node3D



func _on_spawn(data: = {}):
	if data.has("direction"):
		if data["direction"] == -1:
			$SpriteHolder/Sprite.flip_h = true



func _on_sprite_animation_finished() -> void:
	queue_free()
