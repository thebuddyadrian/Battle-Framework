## Custom Sprite3D class that creates a second child sprite that is facing the opposite direction. The second sprite is on a separate cull mask, and is only shown when the camera rotates a certain amount (see components/camera_root.gd)
@tool
extends AnimatedSprite3D
class_name BattleAnimatedSprite3D

@export var flipped: bool = false : set = set_flipped
@export var default_cull_layer: int = 7
@export var flipped_cull_layer: int = 8
var flipped_sprite: AnimatedSprite3D


# Create child flipped_sprite, which is a copy of the current sprite
func _ready():
	await get_tree().physics_frame
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	if !Engine.is_editor_hint():
		layers = 1 << default_cull_layer
		flipped_sprite = AnimatedSprite3D.new()
		for property in flipped_sprite.get_property_list():
			var property_name: StringName = property["name"]
			if property_name == "script":
				continue
			flipped_sprite.set(property_name, get(property_name))
		add_child(flipped_sprite)
		flipped_sprite.layers = 1 << flipped_cull_layer
		animation_changed.connect(_on_animation_changed)
		frame_changed.connect(_on_frame_changed)
	set_flipped(flipped)
	


func set_flipped(p_flipped: bool):
	flipped = p_flipped
	flip_h = flipped
	if flipped_sprite:
		flipped_sprite.flip_h = !flipped


func _on_animation_changed():
	if flipped_sprite:
		flipped_sprite.animation = animation
	


func _on_frame_changed() -> void:
	if flipped_sprite:
		flipped_sprite.frame = frame
