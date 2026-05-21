extends Node
class_name AI_Navigation_Behaviour_Base

# Main body this component is attached too
@export var character:BattleCharacter = null
@export var input_device:PL_Input_Device = null

@export var min_distance_to_target:float = 2.0

var current_target:Node3D = null
var current_target_char:BattleCharacter = null

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
		
		var Target_Diff:Vector3 = current_target.global_position-character.global_position
		var Target_Distance:float = Target_Diff.length()
		#normlize without extra calulations
		if(Target_Distance>0): Target_Diff/=Target_Distance
		
		if(Target_Distance > min_distance_to_target):
			move(-Target_Diff)
		
	
	pass
	
func move(Direction) -> void:
		
	const AngleRefOverlap:float = 60
	
	var Diff_Angle:float = (atan2(Direction.x,Direction.z))
	
	#Temp reconfig later
	var H_Dir = ""
	var V_Dir = ""
	
	if(abs(rad_to_deg(angle_difference(Diff_Angle,0))) < (AngleRefOverlap)):
		V_Dir = "up"
	elif(abs(rad_to_deg(angle_difference(Diff_Angle,PI))) < (AngleRefOverlap)):
		V_Dir = "down"
	if(abs(rad_to_deg(angle_difference(Diff_Angle,PI/2))) < (AngleRefOverlap)):
		H_Dir = "left"
	elif(abs(rad_to_deg(angle_difference(Diff_Angle,-PI/2))) < (AngleRefOverlap)):
		H_Dir = "right"
	
	if(H_Dir != ""): input_device.Call_Input(H_Dir)
	if(V_Dir != ""): input_device.Call_Input(V_Dir)
	
	print("AT ",Diff_Angle, " ",H_Dir, " ",V_Dir)
	
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
	
	current_target_char = Chars[ClosestDistIDX]
	current_target = Chars[ClosestDistIDX]
	return current_target
	
	return null
