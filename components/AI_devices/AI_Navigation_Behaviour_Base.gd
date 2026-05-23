extends Node
class_name AI_Navigation_Behaviour_Base

# Main body this component is attached too
@export var character:BattleCharacter = null
@export var input_device:PL_Input_Device = null

@export var min_distance_to_target:float = 2.0

var current_target:Node3D = null
var current_target_char:BattleCharacter = null

# Path finding

var path_reset:bool = false

# points to go 2
var current_path_points:PackedVector3Array = []
var current_path_idx:int = 0

var current_path_time:float = 0.0

var jump_cooldown:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# find parent add it as a quick reference through character
	var Parent_Character = get_parent()
	if(Parent_Character != null):
		character = (Parent_Character as BattleCharacter)
		input_device = character.Input_Device
		
		character.hurtbox.hurt.connect(Damaged)
		
	find_nearest_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(jump_cooldown > 0): jump_cooldown -= delta
		
	if(current_target != null): # Temp behaviour
		
		var Grounded:bool = character.is_on_floor()
		
		if(current_path_points.size() <= 0):
			
			current_path_time += delta
			
			# Generate path when cooldown is complete
			if(current_path_time >= 2.0 || (path_reset && Grounded)): 
				current_path_idx = 0
				calculate_path_to(current_target.global_position)
				current_path_time = 0.0
				path_reset = false
		else:
			var point_dif = (current_path_points[current_path_idx+1]-current_path_points[current_path_idx])
			var next_height = point_dif.dot(Vector3.UP)
			var current_height = (current_path_points[current_path_idx]-character.global_position).dot(Vector3.UP)
			point_dif -= Vector3.UP*next_height
			var point_dis = (character.global_position-current_path_points[current_path_idx]).dot(-point_dif)
			
			# distance between vertical points will be close, so we can just tell it jump once current path has certain height
			if((next_height >= 0.1 || current_height >= 0.05) && jump_cooldown <= 0.0):
				jump()
		
			if(point_dis <= 0 && Grounded): move_to_next_point()
			
			input_device.OverrideLeftStick = false
			if(current_path_idx < current_path_points.size() || point_dis > min_distance_to_target): 
				var Point_C_Diff = current_path_points[current_path_idx+1] - character.global_position
				move(Point_C_Diff.normalized())
			#if(current_path_idx < current_path_points.size() || point_dis > min_distance_to_target):
				#move(point_dif.normalized())
	
	pass
	
func move_to_next_point() -> void:
	current_path_idx+=1
	if(current_path_idx >= current_path_points.size()-1):
		current_path_idx = 0
		current_path_points.clear()
	
func calculate_path_to(Target:Vector3) -> PackedVector3Array:
	#used to slightly offset path calculation point so points arent in slopes
	
	# Finish path calc
	if(MatchSetup.current_stage_node == null): return []
	current_path_points = NavigationServer3D.map_get_path(character.get_world_3d().navigation_map,character.global_position,Target,true)
	
	return current_path_points
	
func Damaged() -> void:
	path_reset = true
	
func move(Direction) -> void:
	
	input_device.OverrideLeftStick = true
	input_device.LocalOverrideLeftStick = Vector2(Direction.x,Direction.z)
	#
	#const AngleRefOverlap:float = 80
	#
	#var Diff_Angle:float = (atan2(Direction.x,Direction.z))
	#
	##Temp reconfig later
	#var H_Dir = ""
	#var V_Dir = ""
	#
	#if(abs(rad_to_deg(angle_difference(Diff_Angle,0))) < (AngleRefOverlap)):
		#V_Dir = "up"
	#elif(abs(rad_to_deg(angle_difference(Diff_Angle,PI))) < (AngleRefOverlap)):
		#V_Dir = "down"
	#if(abs(rad_to_deg(angle_difference(Diff_Angle,PI/2))) < (AngleRefOverlap)):
		#H_Dir = "left"
	#elif(abs(rad_to_deg(angle_difference(Diff_Angle,-PI/2))) < (AngleRefOverlap)):
		#H_Dir = "right"
	#
	##Move base on require inputs for direction
	#if(H_Dir != ""): input_device.Call_Input(H_Dir)
	#if(V_Dir != ""): input_device.Call_Input(V_Dir)

func jump() -> void:
	input_device.Call_Input("jump")
	jump_cooldown = 0.85
	
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
	
	current_target_char = Chars[ClosestDistIDX] as BattleCharacter
	current_target = Chars[ClosestDistIDX]
	return current_target
	
	return null
