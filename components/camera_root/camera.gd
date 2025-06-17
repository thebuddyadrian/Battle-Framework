## The main camera found in levels.
extends Camera3D
class_name BattleCamera


@export var movespeed := 3.5
@export var rotspeed := 3.5


@onready var root: Node3D = get_node("../..")
@onready var targetpos: Node3D = get_node("../../PositionTarget")
@onready var rotation_target: Node3D = get_node("../../RotationTarget")

var player_id_to_track: int = 1

# Set from the level script if the camera follows the player
var _dont_rotate = false


func _process(delta):
	var targetposex := Vector3.ZERO

	for character: BattleCharacter in get_tree().get_nodes_in_group("characters"):
		if character.player_id == player_id_to_track:
			targetposex += character.global_position
	
	var targetpos2 := Vector3(targetposex.x/1.3, targetposex.y/1.2, targetposex.z)

	targetpos.global_position = targetpos.global_position.lerp(
		targetpos2, min(delta * movespeed, 1.0))
	
	rotation_target.global_position = rotation_target.global_position.lerp(
		targetposex, min(delta * rotspeed, 1.0))
	
	if !_dont_rotate:
		root.global_position = targetpos.global_position
		look_at_from_position(global_position, rotation_target.global_position)
	
