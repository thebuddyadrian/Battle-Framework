@tool
extends BattleSprite3D
# Use this to set the offset, not the position or built in offset, this allows it to be flipped properly
@export var effect_offset: Vector2

func _ready():
	super._ready()
	hide()


func _process(delta: float) -> void:
	flipped = get_parent().flipped
	if flipped:
		offset = -effect_offset
	else:
		offset = effect_offset
	if flipped_sprite:
		flipped_sprite.visible = visible
		if flipped:
			flipped_sprite.offset = effect_offset
		else:
			flipped_sprite.offset = -effect_offset
