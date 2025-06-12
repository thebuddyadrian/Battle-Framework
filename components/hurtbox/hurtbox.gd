@tool
class_name Hurtbox
extends Area3D

enum MODE {NORMAL, SHIELD}

var grabbed_by = ""
var initial_rects = []
var initial_is_reflector: bool
var player_id: int = 0 # Hitboxes cannot hit hurtboxes with the same player_no

signal hurt(hit_data: HitData, hitbox: Hitbox)
signal grabbed
signal escaped_grab
signal released_from_grab
signal thrown

@export var mode: MODE = MODE.NORMAL
@export var active = false
@export var can_be_grabbed = true
@export var can_be_hit = true
@export var root_node_path: NodePath
@export var hit_pause_override := -1
@export var is_reflector = false



@onready var root = get_node(root_node_path)

func _ready():
	assert(root_node_path, "Must set a root node!")
	add_to_group("network_sync")
	add_to_group("hurtbox_group")
	# initial_rects = rects.duplicate(true)
	initial_is_reflector = is_reflector

	if root is BattleCharacter:
		player_id = root.player_id
	if root is BaseSpawnable:
		if root.summoner is BattleCharacter:
			player_id = root.summoner.player_id
	

func _network_process(_input):
	pass # Hitboxes and Hurtboxes are processed inside BaseStage.gd


# func _process(delta):
# 	if !Engine.is_editor_hint():
# 		visible = Global.visible_hurtboxes


func reset():
	active = false
	# rects = initial_rects.duplicate(true)
	# fixed_position = SGFixed.vector2(0,0)
	# fixed_rotation = 0
	mode = MODE.NORMAL
	grabbed_by = ""
	can_be_grabbed = true
	can_be_hit = true
	hit_pause_override = -1
	is_reflector = initial_is_reflector


func get_hit(hit_data, area_hurt_by: Hitbox):
	if root is BattleCharacter:
		if root.invincibility_frames > 0:
			return
	if active and can_be_hit: 
		if mode == MODE.NORMAL:
			emit_signal("hurt", hit_data.duplicate(true), area_hurt_by)
		elif mode == MODE.SHIELD:
			emit_signal("blocked", hit_data.duplicate(true), area_hurt_by)


func get_grabbed(hit_data, area_grabbed_by: Hitbox):
	if !active: return
	if !can_be_grabbed: return
	grabbed_by = area_grabbed_by.root.name
	#emit_signal("grabbed", hit_data.duplicate(true), area_grabbed_by)
	if root.has_method("_hurtbox_grabbed"):
		root._hurtbox_grabbed(hit_data.duplicate(true), area_grabbed_by)


func get_released_from_grab(area_released_from: Hitbox):
	if !grabbed_by: return
	grabbed_by = ""
	emit_signal("released_from_grab", area_released_from)


func get_thrown(area_thrown_by: Hitbox):
	if !grabbed_by: return
	grabbed_by = ""
	#emit_signal("thrown", area_thrown_by)
	if root.has_method("_hurtbox_thrown"):
		root._hurtbox_thrown(area_thrown_by)


func escape_from_grab():
	if !grabbed_by: return
	grabbed_by = ""
	#emit_signal("escaped_grab")
	if root.has_method("_hurtbox_escaped_grab"):
		root._hurtbox_escaped_grab()


func _save_state() -> Dictionary:
	return {
		#rects = rects.duplicate(true),
		active = active,
		mode = mode,
		grabbed_by = grabbed_by,
		can_be_grabbed = can_be_grabbed,
		can_be_hit = can_be_hit,
		hit_pause_override = hit_pause_override,
		is_reflector = is_reflector,
	}


func _load_state(_state: Dictionary):
	#rects = _state["rects"].duplicate(true)
	active = _state["active"]
	mode = _state["mode"]
	grabbed_by = _state["grabbed_by"]
	can_be_grabbed = _state["can_be_grabbed"]
	can_be_hit = _state["can_be_hit"]
	hit_pause_override = _state["hit_pause_override"]
	is_reflector = _state["is_reflector"]
	# update_contact_boxes()
	# sync_to_physics_engine()
