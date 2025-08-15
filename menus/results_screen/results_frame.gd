extends TextureRect

var twn : Tween = create_tween()

func _ready() -> void:
	position.x = 240
	twn.tween_property(self,"position",Vector2(48,0),0.3)
