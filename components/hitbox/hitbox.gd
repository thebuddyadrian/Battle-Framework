@tool
class_name Hitbox
extends Area3D

const REBOUND_THRESHOLD: int = 20
# const HIT_SPARK_PATH = "res://Effects/HitSparkEffect/HitSparkEffect.tscn"
# const CLASH_EFFECT_PATH = "res://Effects/ClashEffect/ClashEffect.tscn"

@export var hit_data: HitData = HitData.new()
@export var active := false : set = set_active
@export var root_node_path: NodePath
#Z@export var hit_spark_pos_node_path: NodePath
@export var is_static: bool = false # For Projectiles with hitboxes that never change
@export var total_area: float = 0

var nodes_already_hit = []
var character_last_hit := "" # Node name of character last hit
var character_grabbed := "" # Node name of character currently grabbed
var initial_hit_data: Resource
var initial_rects = []
var player_id: int = 0

@onready var root = get_node(root_node_path)
# @onready var hit_spark_pos_node: SGFixedNode2D = get_node_or_null(hit_spark_pos_node_path)
# @onready var stage = CurrentMatch.root

signal hit(hit_data: HitData, hurtbox: Hurtbox)
signal clash
signal grab
signal blocked


func _ready():
	assert(root_node_path, "Must set a root node for %s!" % name)
	#Make sure hit info isn't shared between multiple hitbox groups
	hit_data = hit_data.duplicate(true)
	# Used to reset the Hitbox to it's initial state
	initial_hit_data = hit_data
	#initial_rects = rects.duplicate(true)
	add_to_group("network_sync")
	add_to_group("hitbox_group")

	if root is BattleCharacter:
		player_id = root.player_id
	if root is BaseSpawnable:
		if root.summoner is BattleCharacter:
			player_id = root.summoner.player_id
	


func reset():
	nodes_already_hit.clear()
	active = false
	hit_data = initial_hit_data
	hit_data.root_name = ""
	hit_data.direction = 1
	character_last_hit = ""
	character_grabbed = ""
	#rects = initial_rects.duplicate(true)
	# fixed_position = SGFixed.vector2(0,0)
	# fixed_rotation = 0


# func _process(delta):
# 	if Engine.is_editor_hint():
# 		total_area = 0
# 		for rect in rects:
# 			total_area += rect.get_area()
# 	else:
# 		if Global.visible_hitboxes:
# 			visible = active
# 		else:
# 			visible = false


func check_if_hit(hurtbox) -> bool:
	if !active: 
		return false
	if hurtbox.is_in_group("hurtbox_group"):
		if hurtbox.active:
			if hurtbox.root is BattleCharacter:
				if hurtbox.root.invincibility_frames > 0:
					return false
			if (hurtbox.can_be_hit and hurtbox.mode == Hurtbox.MODE.NORMAL):# or (hit_data.type == HitData.MOVE_TYPES.GRAB and hurtbox.can_be_grabbed):
				if !(get_path_to(hurtbox.root) in nodes_already_hit):
					if hurtbox.root != root and hurtbox.player_id != player_id:
						return true
	return false


func check_if_clash(hitbox) -> bool:
	if !active:
		return false
	if hitbox.is_in_group("hitbox_group"):
		if hitbox.active:
			if !(hitbox.root.is_in_group("characters")): return true
			if !(get_path_to(hitbox.root) in nodes_already_hit):
				return true
	return false
		

func check_if_blocked(hurtbox) -> bool:
	if !active: return false
	if hit_data.unblockable: return false
	if hurtbox.is_in_group("hurtbox_group"):
		if hurtbox.active and hurtbox.can_be_hit and hurtbox.mode == Hurtbox.MODE.SHIELD:
			#if hurtbox.root.team_id != root.team_id and !(get_path_to(hurtbox.root) in nodes_already_hit):
				#return true
			if !(get_path_to(hurtbox.root) in nodes_already_hit):
				return true
	return false


func is_hitting_wall() -> bool:
	if !active: return false
	for body in get_overlapping_bodies():
		if body.is_in_group("platform"):
			return true
	return false

# Tell the hurtbox they were hit
func do_hit(hurtbox):
	nodes_already_hit.append(get_path_to(hurtbox.root))
	
	var processed_hit_data: HitData = hit_data.duplicate(true)
	if root.has_method("_hit_data_preprocess"):
		root._hit_data_preprocess(processed_hit_data)
		
	# if processed_hit_data.type == HitData.MOVE_TYPES.GRAB:
	# 	if !character_grabbed and hurtbox.root.is_in_group("character"):
	# 		hurtbox.get_grabbed(processed_hit_data.duplicate(), self)
			
	# 		if !hurtbox.is_connected("escaped_grab", self, "opponent_escaped_grab"):
	# 			hurtbox.connect("escaped_grab", self, "opponent_escaped_grab")
	# 		#emit_signal("grab", processed_hit_data, hurtbox)
	# 		if root.has_method("_hitbox_grab"):
	# 			root._hitbox_grab(processed_hit_data, hurtbox)
	# 		character_last_hit = hurtbox.root.name
	# 		character_grabbed = hurtbox.root.name
	# 	return
		
	character_last_hit = hurtbox.root.name
	print("Hitbox.gd: %s" % processed_hit_data.knockback_direction)
	emit_signal("hit", processed_hit_data, hurtbox)
	hurtbox.get_hit(processed_hit_data.duplicate(true), self)
#	spawn_hit_spark_effect(hurtbox.get_global_fixed_position().x)


# func clash(hitbox):
# 	var self_priority: int = hit_data.damage if hit_data.priority_override < 0 else hit_data.priority_override
# 	var other_priority: int = hitbox.hit_data.damage if hitbox.hit_data.priority_override < 0 else hitbox.hit_data.priority_override
# 	var rebound: bool = self_priority <= other_priority + REBOUND_THRESHOLD
# 	if rebound:
# 		nodes_already_hit.append(get_path_to(hitbox.root))
# 	#emit_signal("clash", hit_data, hitbox)
# 	if root.has_method("_hitbox_clash"):
# 		root._hitbox_clash(hit_data, hitbox, rebound)
# 	spawn_clash_effect(hitbox)


# func get_hit_fx_position() -> SGFixedVector2:
# 	if hit_spark_pos_node:
# 		return hit_spark_pos_node.get_global_fixed_position()
# 	return SGFixed.vector2(hit_data.fx_position_x, hit_data.fx_position_y).add(get_global_fixed_position())


# func spawn_hit_spark_effect(pos_x: int = get_hit_fx_position().x, pos_y: int = get_hit_fx_position().y):
# 	var data = {
# 		fixed_position_x = pos_x,
# 		fixed_position_y = pos_y,
# 		color = hit_data.fx_color_hex,
# 	}
# 	SyncManager.spawn("HitSparkEffect", stage, load(HIT_SPARK_PATH), data.duplicate(true))


# func spawn_clash_effect(area_clashed: SGContactBoxGroup):
# 	var my_pos = SGFixed.vector2(get_global_fixed_position().x, get_hit_fx_position().y)
# 	var other_pos = SGFixed.vector2(area_clashed.root.get_global_fixed_position().x, area_clashed.get_hit_fx_position().y)
# 	var midpoint = my_pos.add(other_pos).div(2*65536)
	
# 	var data: Dictionary = {
# 		fixed_position_x = midpoint.x,
# 		fixed_position_y = midpoint.y,
# 	}
	
# 	SyncManager.spawn("ClashEffect", stage, load(CLASH_EFFECT_PATH), data.duplicate(true))


func confirm_blocked(hurtbox):
	nodes_already_hit.append(get_path_to(hurtbox.root))
	hurtbox.get_hit(hit_data.duplicate(true), self)
	character_last_hit = hurtbox.root.name
	emit_signal("blocked", hit_data, hurtbox)
	#spawn_hit_spark_effect(hurtbox.get_global_fixed_position().x)


# func release_grabbed_opponent():
# 	if !character_grabbed: return
# 	var character_node = CurrentMatch.get_character(character_grabbed)
# 	if character_node.is_in_group("character"): character_node.hurtbox.released_from_grab(self)
# 	character_grabbed = ""


func opponent_escaped_grab():
	character_grabbed = ""


func set_active(_active: bool):
	active = _active
	if active:
		nodes_already_hit.clear()


func _save_state() -> Dictionary:
	var state = {
		#rects = rects.duplicate(true),
		active = active,
		nodes_already_hit = nodes_already_hit.duplicate(true),
		# fixed_position_x = fixed_position.x,
		# fixed_position_y = fixed_position.y,
		# fixed_rotation = fixed_rotation,
		character_last_hit = character_last_hit,
		character_grabbed = character_grabbed,
	}
	if !is_static:
		state["hit_data"] = hit_data.get_as_dict()
	else:
		state["hit_data_direction"] = hit_data.direction
	return state


func _load_state(_state: Dictionary):
	active = _state["active"]
	# rects = _state["rects"].duplicate(true)
	# nodes_already_hit = _state["nodes_already_hit"].duplicate(true)
	# fixed_position.x = _state["fixed_position_x"]
	# fixed_position.y = _state["fixed_position_y"]
	# fixed_rotation = _state["fixed_rotation"]
	# if _state.has("hit_data"):
	# 	hit_data = Functions.hit_data_from_dict(_state["hit_data"].duplicate(true))
	if _state.has("hit_data_direction"):
		hit_data.direction = _state["hit_data_direction"]
	character_grabbed = _state["character_grabbed"]
	character_last_hit = _state["character_last_hit"]
	# update_contact_boxes()
	# sync_to_physics_engine()
