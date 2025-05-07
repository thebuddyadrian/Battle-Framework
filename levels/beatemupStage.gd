## A base class for all levels.
@tool
extends Node3D
class_name BEUStage

@export var music  : AudioStream
@onready var camera = $Camera3D
var audiostreamplayer = AudioStreamPlayer.new()
@onready var player = $Sonic

func _ready() -> void:
	MusicPlayer.play_track(music)
	
	player.camera = camera
	player.scale = Vector3(4, 4, 4)
	player.name = str(player.player_id)
	player.char_name = "sonic"
	
	await get_tree().process_frame


func _physics_process(delta: float) -> void:
		# TO-DO Make a utility function to sort dictionaries instead of having all this code
	var hitbox_groups_unsorted = {}
	var hurtbox_groups_unsorted = {}

	for hitbox_group in get_tree().get_nodes_in_group("hitbox_group"):
		hitbox_groups_unsorted[get_path_to(hitbox_group)] = hitbox_group

	for hurtbox_group in get_tree().get_nodes_in_group("hurtbox_group"):
		hurtbox_groups_unsorted[get_path_to(hurtbox_group)] = hurtbox_group

	var hitbox_group_paths_sorted = hitbox_groups_unsorted.keys()
	var hurtbox_group_paths_sorted = hurtbox_groups_unsorted.keys()
	hitbox_group_paths_sorted.sort()
	hurtbox_group_paths_sorted.sort()

	var hitbox_groups = []
	for hitbox_node_path in  hitbox_group_paths_sorted:
		hitbox_groups.append(hitbox_groups_unsorted[hitbox_node_path])

	var hurtbox_groups = []
	for hurtbox_node_path in  hurtbox_group_paths_sorted:
		hurtbox_groups.append(hurtbox_groups_unsorted[hurtbox_node_path])


	#for hurtbox_group in hurtbox_groups:
		#hurtbox_group.update_contact_boxes()
		#hurtbox_group.sync_to_physics_engine()
		
	var hurt_areas = {}
	var clash_areas = {}
	var blocked_areas = {}
	
	# Check for blocked and clashed attacks first
	for hitbox_group in hitbox_groups:
		if !hitbox_group.active:
			continue
		#if !hitbox_group.is_static:
			#hitbox_group.update_contact_boxes()
		#hitbox_group.sync_to_physics_engine()

		hurt_areas[hitbox_group] = []
		clash_areas[hitbox_group] = []
		blocked_areas[hitbox_group] = []

		for area in hitbox_group.get_overlapping_areas():
			if hitbox_group.check_if_blocked(area):
				blocked_areas[hitbox_group].append(area)
			if hitbox_group.check_if_clash(area):
				clash_areas[hitbox_group].append(area)
				if !clash_areas.has(area):
					clash_areas[area] = []
				clash_areas[area].append(hitbox_group)

	# Confirmed blocked attacks
	for hitbox in blocked_areas:
		for hurtbox in blocked_areas[hitbox]:
			hitbox.confirm_blocked(hurtbox)
			clash_areas[hitbox] = []
	
	# for hitbox in clash_areas:
	# 	for hurtbox in clash_areas[hitbox]:
	# 		hitbox.clash(hurtbox)
	# 		hurt_areas[hitbox] = []

	# Check for hit attacks
	for hitbox_group in hitbox_groups:
		hurt_areas[hitbox_group] = []
		for area in hitbox_group.get_overlapping_areas():
			if hitbox_group.check_if_hit(area):
				hurt_areas[hitbox_group].append(area)

	for hitbox in hurt_areas:
		for hurtbox in hurt_areas[hitbox]:
			hitbox.do_hit(hurtbox)


func _on_area_3d_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
