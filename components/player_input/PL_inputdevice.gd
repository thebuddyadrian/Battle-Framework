extends Node
## New input recieve implmented for online and AI overrides for player controls
class_name PL_Input_Device

# not needed long term just temp, use player where possible
var ID:int = -1
# Uses the input method to retrive inputs, otherwise local overrides take hold
var Auto_Assign:bool = false

const IDToInputType:Dictionary[int,String] = {
	0:"none",
	1:"pressed",
	2:"just_pressed",
	3:"just_released"
}

# Add input overrides as needed
var LocalOverridedPressedInputs:Dictionary ={
	
}

# Assign override inputs here for actions here rather call input check with id on end
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

# Representation of inputs for up down left right as vector with overrides
var LeftStick:Vector2 = Vector2(0,0)

@export var OverrideLeftStick:bool = false
var LocalOverrideLeftStick:Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var Parent = get_parent()
	if(Parent != null):
		var Character = (Parent as BattleCharacter)
		ID = Character.player_id
		Character.Input_Device = self
		
func _process(delta: float) -> void:
	
	# Only used for Override input options or manual control
	if(!Auto_Assign): 
		for Override in LocalOverridedPressedInputs.keys():
			if(LocalOverridedPressedInputs[Override] == true):
				#reset inputs if pressed
				if(LocalOverridedInputs[Override] > 0): LocalOverridedInputs[Override] = 1
				else: LocalOverridedInputs[Override] = 2
			else:
				#Switch states for input if not pressed
				if(LocalOverridedInputs[Override] == 1): LocalOverridedInputs[Override] = 2
				elif(LocalOverridedInputs[Override] == 3 || LocalOverridedInputs[Override] == 2): LocalOverridedInputs[Override] = 0
				else: LocalOverridedInputs[Override] = 3
				
			# Deactive unless call_input is called each frame
			LocalOverridedPressedInputs[Override] = false
	
		# Left Stick caluclations
		if(OverrideLeftStick): 
			LeftStick = LocalOverrideLeftStick
		else:
			LeftStick = Vector2(int(LocalOverridedInputs["right"]>0)-int(LocalOverridedInputs["left"]>0),int(LocalOverridedInputs["up"]>0)-int(LocalOverridedInputs["down"]>0))
	else:
		# Joystick direct axis
		LeftStick = inputvec(ID)
	
## Auto assigned input based on player ID or AI device
func input(action: StringName, type: String = "pressed") -> bool:
	if(ID < 0): return false
	if(Auto_Assign): # Player based input
		#Static return for inputs based on ID, disabled for Ai
		return inputfrom(ID,action,type)
	#Localized controls
	return inputOverrides(action,type)

static func inputvec(ID:int) -> Vector2:
	return Input.get_vector("left"+str(ID),"right"+str(ID),"up"+str(ID),"down"+str(ID))

# we include here rather than an override class or node because it adds a single frame of latency which if we're not careful can add up
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
func Call_Input(action: StringName, OverrideState: int = -1) -> void:
	# kill if input isnt real
	if(!LocalOverridedInputs.has(action)): return
	if(OverrideState >= 0): LocalOverridedPressedInputs[action] = OverrideState
	else: LocalOverridedPressedInputs[action] = true
