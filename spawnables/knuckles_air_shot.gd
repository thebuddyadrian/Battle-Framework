extends BaseSpawnable

func _on_spawn(data: = {}):
	$Sprite.show()
	direction = data["direction"]
	sprite.play("Throw")
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
	elif direction == Vector2.RIGHT:
		$Sprite.flip_h = false


func _do_behavior(delta):
	if is_on_floor():
		velocity = Vector3.ZERO
		sprite.play("Break")
		

# func _on_sprite_animation_finished() -> void:
# 	if sprite.animation == "Break":
# 		queue_free()
