## The main camera found in levels.
extends Camera3D
class_name Camera


@export var movespeed := 5.0
@export var rotspeed := 5.0

# Set from the level script if the camera follows the player
var _dont_rotate = false


func _process(delta):
	pass
