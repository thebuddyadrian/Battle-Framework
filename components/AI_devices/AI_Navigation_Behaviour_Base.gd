extends Node
class_name AI_Navigation_Behaviour_Base

# Main body this component is attached too
@export var character:BattleCharacter = null
@export var input_device:PL_Input_Device = null

var current_target:BattleCharacter = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# find parent add it as a quick reference through character
	var Parent_Character = get_parent()
	if(Parent_Character != null):
		character = (Parent_Character as BattleCharacter)
		input_device = character.Input_Device
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	input_device.Call_Input("left")
	
	pass
	
func find_nearest_target() -> BattleCharacter:
	
	return null
