extends BaseSpawnable

func _on_spawn(data: = {}):
	$AnimationPlayer.play("Anim")
	direction = data["direction"]
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true
	$Hitbox/Shape.disabled = true
	$Hurtbox/Shape.disabled = true
	$CollisionShape3D.disabled = true
