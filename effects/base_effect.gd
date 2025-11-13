extends Node3D
class_name BaseEffect

@export var destroy_on_animation_finish := true
@export var animated_sprite: BattleAnimatedSprite3D
@export var use_player_direction := true



func _ready() -> void:
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)


func _on_spawn(data: = {}):
	if use_player_direction and animated_sprite:
		var dir = data.get("dir", 0)
		if dir <= 0:
			animated_sprite.flipped = true
		else:
			animated_sprite.flipped = false


func _on_animation_finished():
	if destroy_on_animation_finish:
		queue_free()
