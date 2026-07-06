extends Node
class_name AI_Navigation_Behaviour_Base

@export var AI_Behaviour_settings:AI_NAV_Pref = preload("res://ai_cpu/DefaultAI.tres")
# Currently non functional, place holder until attacking functions are added
@export_range(1,5) var AI_Level:int = 1
# Every hit gets them angrier which causes the time between attacks to decrease
var Current_Agression_range:float = 0.0

# Contains items which cannot be target by AI
@export var blacklisted_targets:Array[Node] = []

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
# time spent on moving to next point
var current_point_time:float = 0.0

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
	
	if(Current_Agression_range > 0): Current_Agression_range -= delta
		
	if(current_target != null): # Temp behaviour
		
		if(path_reset):
			reset_path()
		
		var Grounded:bool = character.is_on_floor()
		
		if(current_path_points.size() <= 0):
			
			current_path_time += delta
			
			# Generate path when cooldown is complete
			if(current_path_time >= .5): 
				path_reset = true
		else:
			
			current_point_time += delta
			
			var point_dif = (current_path_points[current_path_idx+1]-current_path_points[current_path_idx])
			var next_height = point_dif.dot(Vector3.UP)
			var current_height = (current_path_points[current_path_idx]-character.global_position).dot(Vector3.UP)
			point_dif -= Vector3.UP*next_height
			var point_dis = (character.global_position-current_path_points[current_path_idx]).dot(-point_dif)
			
			# distance between vertical points will be close, so we can just tell it jump once current path has certain height
			if((next_height >= 0.1 || current_height >= 0.05) && jump_cooldown <= 0.0):
				jump()
		
			if(point_dis <= 0 && Grounded): 
				move_to_next_point()
				current_point_time = 0.0
				
			# if the characters been targeting one spot for too long, reset
			if(current_point_time > 1.0):
				path_reset = true
			
			input_device.OverrideLeftStick = false
			if(current_path_idx < current_path_points.size() || point_dis > min_distance_to_target): 
				var Point_C_Diff = current_path_points[current_path_idx+1] - character.global_position
				move(Point_C_Diff.normalized())
			#if(current_path_idx < current_path_points.size() || point_dis > min_distance_to_target):
				#move(point_dif.normalized())
	
	pass
	
	
func reset_path() -> void:
	# Generate path when cooldown is complete
	current_path_idx = 0
	calculate_path_to(current_target.global_position)
	current_path_time = 0.0
	current_point_time = 0.0
	path_reset = false
	
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
	
func Damaged(hitdata:HitData, hitbox:Hitbox) -> void:
	# will need to be change in new update to find parent from hitbox
	var HitFrom = hitbox.get_parent_node_3d()
	if(blacklisted_targets.count(HitFrom) <= 0):
		current_target = hitbox.get_parent_node_3d()
		current_target_char = current_target as BattleCharacter
	
	Current_Agression_range = clamp(1.0,0,AI_Level * 2)
	path_reset = true
	
func move(Direction) -> void:
	# Sets the stick override then, sets the input device to use the new left stick override
	input_device.OverrideLeftStick = true
	input_device.LocalOverrideLeftStick = Vector2(Direction.x,Direction.z)

func jump() -> void:
	input_device.Call_Input("jump")
	jump_cooldown = 0.85
	
func find_nearest_target() -> BattleCharacter:
	var Chars = get_tree().get_nodes_in_group("characters")
	Chars.erase(character)
	
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
		if(Dist <= ClosestDistRef ):
			ClosestDistIDX = CharacterIDX
			ClosestDistRef = Dist
	
	current_target_char = Chars[ClosestDistIDX] as BattleCharacter
	current_target = Chars[ClosestDistIDX]
	return current_target
	
	return null
