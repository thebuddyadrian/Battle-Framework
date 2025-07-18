@tool
extends BattleSprite3D

# Use this to set the offset, not the position or built in offset, this allows it to be flipped properly
@export var effect_offset: Vector2

func _ready():
	hide()


func _process(delta: float) -> void:
	offset = effect_offset
	if flipped_sprite:
		flipped_sprite.offset = -effect_offset
