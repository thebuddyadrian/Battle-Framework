extends BaseSpawnable

@onready var rock_break_sfx: AudioStreamPlayer3D = $RockBreakSFX
@onready var direct_hit_shape: CollisionShape3D = $Hitbox/DirectHitShape
@onready var explosion_shape: CollisionShape3D = $Hitbox/ExplosionShape

func _on_spawn(data: = {}):
	sprite.show()
	direction = data["direction"]
	sprite.play("Throw")
	if direction == Vector2.LEFT:
		sprite.flip_h = true
	elif direction == Vector2.RIGHT:
		sprite.flip_h = false
	# Direct hit hitbox does 25 damage
	hitbox.hit_data.damage = 25


func _do_behavior(delta):
	if is_on_floor() and !sprite.animation == "Break":
		velocity = Vector3.ZERO
		# Enable explosion shape so the hitbox becomes bigger after breaking
		direct_hit_shape.disabled = true
		explosion_shape.disabled = false
		sprite.play("Break")
		# Reset hitbox so it can hit again
		hitbox.active = true
		# Explosion hitbox does 15 damage
		hitbox.hit_data.damage = 15
		if !rock_break_sfx.playing:
			rock_break_sfx.play()

func _on_sprite_animation_finished():
	if sprite.animation == "Break":
		queue_free()
