extends BaseSpawnable

@onready var rock_break_sfx: AudioStreamPlayer3D = $RockBreakSFX

func _on_spawn(data: = {}):
	sprite.show()
	direction = data["direction"]
	sprite.play("Throw")
	if direction == Vector2.LEFT:
		sprite.flip_h = true
	elif direction == Vector2.RIGHT:
		sprite.flip_h = false


func _do_behavior(delta):
	if is_on_floor() and !sprite.animation == "Break":
		velocity = Vector3.ZERO
		sprite.play("Break")
		if !rock_break_sfx.playing:
			rock_break_sfx.play()

func _on_sprite_animation_finished():
	if sprite.animation == "Break":
		queue_free()
