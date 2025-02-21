## The main camera found in levels.
extends Camera3D
class_name Camera


@export var movespeed := 5.0
@export var rotspeed := 5.0


@onready var root: Node3D = get_node("../..")
@onready var targetpos: Node3D = get_node("../../PositionTarget")
@onready var rotation_target: Node3D = get_node("../../RotationTarget")

# Set from the level script if the camera follows the player
var _dont_rotate = false


func _process(delta):
	var targetposex := Vector3.ZERO

	for character: BattleCharacter in get_tree().get_nodes_in_group("characters"):
		targetposex += character.global_position
	
	targetposex /= get_tree().get_node_count_in_group("characters")

	var targetpos2 := Vector3(targetposex.x/1.3, targetposex.y/1.2, targetposex.z)

	targetpos.global_position = targetpos.global_position.lerp(
		targetpos2, min(delta * movespeed, 1.0))
	
	rotation_target.global_position = rotation_target.global_position.lerp(
		targetposex, min(delta * rotspeed, 1.0))
	
	if !_dont_rotate:
		root.global_position = targetpos.global_position
		look_at_from_position(global_position, rotation_target.global_position)
	
	
