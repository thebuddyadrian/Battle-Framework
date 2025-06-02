extends BaseSpawnable
var animation_ended: bool

func _on_spawn(data: = {}):
	direction = data["direction"]
	if direction == Vector2.LEFT:
		$Sprite.flip_h = true


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_on_floor():
		queue_free()


func _on_multi_hit_timer_timeout() -> void:
	reactivate_hitbox()
