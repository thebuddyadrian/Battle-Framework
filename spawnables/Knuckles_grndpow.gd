extends BaseSpawnable

func _on_spawn(data: = {}):
	$Sprite.show()
	$AnimationPlayer.play("Anim")
	direction = data["direction"]
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true


func _physics_process(delta: float) -> void:
	if is_on_floor():
		destroy()


func destroy():
	velocity = Vector3.ZERO
	sprite.play("Break")

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "Break":
		queue_free()
