## Custom Sprite3D class that creates a second child sprite that is facing the opposite direction. The second sprite is on a separate cull mask, and is only shown when the camera rotates a certain amount (see components/camera_root.gd)
@tool
extends Sprite3D
class_name BattleSprite3D

@export var flipped: bool = false : set = set_flipped
@export var default_cull_layer: int = 7
@export var flipped_cull_layer: int = 8
var flipped_sprite: Sprite3D


# Create child flipped_sprite, which is a copy of the current sprite
func _ready():
	await get_tree().physics_frame
	if !Engine.is_editor_hint():
		layers = 1 << default_cull_layer
		flipped_sprite = Sprite3D.new()
		flipped_sprite.texture = texture
		flipped_sprite.frame = frame
		flipped_sprite.billboard = billboard
		flipped_sprite.texture_filter = texture_filter
		flipped_sprite.hframes = hframes
		flipped_sprite.vframes = vframes
		add_child(flipped_sprite)
		flipped_sprite.layers = 1 << flipped_cull_layer
	set_flipped(flipped)


func set_flipped(p_flipped: bool):
	flipped = p_flipped
	flip_h = flipped
	if flipped_sprite:
		flipped_sprite.flip_h = !flipped


func _on_texture_changed() -> void:
	if flipped_sprite:
		flipped_sprite.texture = texture


func _on_frame_changed() -> void:
	if flipped_sprite:
		flipped_sprite.frame = frame
