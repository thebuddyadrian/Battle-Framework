@tool
extends Sprite3D

# Use this to set the offset, not the position or built in offset, this allows it to be flipped properly
@export var effect_offset: Vector2


func _process(delta: float) -> void:
	offset = effect_offset
	#AirPow offset: x=1.0 y=3.0
	if flip_h:
		offset *= -1
