extends BaseEffect

@onready var destroy_timer: Timer = $DestroyTimer

func _on_spawn(data := {}):
	super._on_spawn(data)
	print(data["dir"])
	print(animated_sprite.flipped)
	var direction: Vector2 = data["direction"]
	if direction == Vector2.UP:
		animated_sprite.animation = "Up"
	if direction == Vector2.LEFT:
		animated_sprite.animation = "Fwd"
	if direction == Vector2.RIGHT:
		animated_sprite.animation = "Fwd"
	if direction == Vector2.DOWN:
		animated_sprite.animation = "Down"
	animated_sprite.frame = data.get("frame", 0)
	destroy_timer.start()


func _on_destroy_timer_timeout():
	queue_free()
