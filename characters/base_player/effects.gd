@tool
extends Sprite3D

# Use this to set the offset, not the position or built in offset, this allows it to be flipped properly
@export var effect_offset: Vector2


func _process(delta: float) -> void:
    offset = effect_offset
    if flip_h:
        offset *= -1