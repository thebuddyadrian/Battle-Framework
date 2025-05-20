extends BattleCharacter
@onready var shadow_sprite = $PlayerSprite/EffectsSprites
var flip_factor: int = 1
func _process(delta: float) -> void:
	shadow_sprite.flip_h = $PlayerSprite.flip_h
	if shadow_sprite.flip_h:
		flip_factor = -1
	else:
		flip_factor = 1
	if animplayer.current_animation == "Upper":
			shadow_sprite.position.x = 0.06 * flip_factor
	elif animplayer.current_animation == "Heavy":
		shadow_sprite.position.x = -0.02 * flip_factor
