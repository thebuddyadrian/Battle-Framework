extends Node
## New input recieve implmented for online and AI overrides for player controls
class_name PL_Input_Device

var ID:int = -1
var Auto_Assign:bool = true

const IDToInputType:Dictionary[int,String] = {
	0:"none",
	1:"pressed",
	2:"just_pressed",
	3:"just_released"
}

#Assign override inputs here for actions here rather call input check with id on end
var LocalOverridedInputs:Dictionary = {
	"left":0,
	"right":0,
	"up":0,
	"down":0,
	"jump":0,
	"attack":0,
	"skill":0,
	"guard":0,
	"dash":0,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var Parent = get_parent()
	if(Parent != null):
		ID = (Parent as BattleCharacter).player_id
	
## Auto assigned input based on player ID or AI device
func input(action: StringName, type: String = "pressed") -> bool:
	if(ID < 0): return false
	if(Auto_Assign): # Player based input
		#Static return for inputs based on ID, disabled for Ai
		return inputfrom(ID,action,type)
	#Localized controls
	return inputOverrides(action,type)
	
## Input helper function to get input for the current player
## In the future this will also retrieve inputs received over the network (for online play)
static func inputfrom(ID:int, action: StringName, type: String = "pressed") -> bool:
	# Gets the correct action based on the player number (ex: attack1, attack2, attack3, etc.)
	var player_action = action + str(ID)
	if !InputMap.has_action(player_action):
		push_error("Action %s doesn't exist" % player_action)
		return false
	if type == "pressed":
		return Input.is_action_pressed(player_action)
	if type == "just_pressed":
		return Input.is_action_just_pressed(player_action)
	if type == "just_released":
		return Input.is_action_just_released(player_action)
	return false
	
func inputOverrides(action: StringName, type: String = "pressed") -> bool:
	if LocalOverridedInputs.has(action):
		#convert local input ints to input string type e.g. pressed, just_pressed, just_released
		return IDToInputType[LocalOverridedInputs[action]] == type
	return false

## Non Static function to call localized input fields overiding default input methods out
func Call_Input(action: StringName) -> void:
	pass
