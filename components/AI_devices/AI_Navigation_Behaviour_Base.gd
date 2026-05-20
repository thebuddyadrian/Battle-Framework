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
	
	find_nearest_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(current_target != null): # Temp behaviour
		var H_Dir = "left"
		var V_Dir = "up"
		
		if(current_target.global_position.x > character.global_position.x):
			H_Dir = "right"
		if(current_target.global_position.z > character.global_position.z):
			V_Dir = "down"
			
		input_device.Call_Input(H_Dir)
		input_device.Call_Input(V_Dir)
		
	
	pass
	
func find_nearest_target() -> BattleCharacter:
	var Chars = get_tree().get_nodes_in_group("characters")
	Chars.remove_at(Chars.find(character))
	
	if Chars.size() <= 0 : return null
	if Chars.size() <= 1 : 
		current_target = Chars[0]
		return current_target
	
	#Calculate closest character
	var ClosestDistIDX = 0
	var ClosestDistRef = 2048.0 # Max distance? No
	
	for CharacterIDX in range(1,Chars.size()):
		var Diff = Vector3(Chars[CharacterIDX].global_position - character.global_position)
		var Dist = Diff.length()
		if(Dist <= ClosestDistRef):
			ClosestDistIDX = CharacterIDX
			ClosestDistRef = Dist
	
	current_target = Chars[ClosestDistIDX]
	return current_target
	
	return null
