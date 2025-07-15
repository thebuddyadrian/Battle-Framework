## A base class for all levels.
@tool
extends Node3D
class_name Level

const CAMERA_ROOT = preload("res://components/camera_root/camera_root.tscn")
const PLAYER_WINDOW = preload("res://components/player_window/player_window.tscn")
const PLAYER_HUD = preload("res://components/player_hud/player_hud.tscn")

@export var stage_info: StageInfo
@export var player_spawn_1: Node3D
@export var player_spawn_2: Node3D
@export var player_spawn_3: Node3D
@export var player_spawn_4: Node3D
@export var camera_follows_player: bool = false # For beat-em-up levels
@export var camera_root_parent: Node = self
@export var test_characters: Array[String] = ["sonic", "tails"]
var camera_pivots: Dictionary[int, Node3D]
var cameras: Dictionary[int, Camera3D]
var audiostreamplayer = AudioStreamPlayer.new()

@export_tool_button("Export as Mod PCK") var export_as_mod_pck = do_export_as_mod_pck


func _ready() -> void:
	# Get music track
	if stage_info:
		if stage_info.music_file_path:
			print("Loading music track %s" % stage_info.music_file_path)
			MusicPlayer.play_track(load(stage_info.music_file_path))
	
	# If no characters have been selected, use test characters
	if Game.character_choices.is_empty():
		Game.human_players = test_characters.size()
		for i in range(test_characters.size()):
			Game.character_choices[i + 1] = test_characters[i]
	
	# Spawn cameras
	for i in range(Game.human_players):
		
		var camera_root = CAMERA_ROOT.instantiate()
		# For players 2-4, spawn a separate window
		if i > 0:
			var window = PLAYER_WINDOW.instantiate()
			camera_root_parent.add_child(window)
			window.add_child(camera_root)
		else:
			camera_root_parent.add_child(camera_root)
		camera_root.name = "CameraRoot" + str(i + 1)
		var camera_pivot = camera_root.get_node("Pivot")
		var camera = camera_root.get_node("Pivot/Camera")
		camera_pivots[i] = camera_pivot
		cameras[i] = camera
	
	# Spawn characters
	assert(player_spawn_1, "No spawn position has been placed for player 1")
	assert(player_spawn_2, "No spawn position has been placed for player 2")
	assert(player_spawn_3, "No spawn position has been placed for player 3")
	assert(player_spawn_3, "No spawn position has been placed for player 4")
	for i in range(Game.human_players):
		var character = Game.character_choices[i + 1]
		var player: BattleCharacter = load("res://characters/%s/%s.tscn" % [character, character]).instantiate()
		var spawn_position: Node3D = get("player_spawn_%s" % str(i + 1))
		player.global_position = spawn_position.global_position
		player.camera = camera_pivots[i]
		player.scale = Vector3(4, 4, 4)
		player.player_id = i + 1
		cameras[i].player_id_to_track = i + 1
		player.name = str(player.player_id)
		player.char_name = character
		spawn_position.get_parent().add_child(player)

		# Spawn HUD
		var player_hud = PLAYER_HUD.instantiate()
		cameras[i].add_child(player_hud)
		player_hud.track_player(player)

	
	# if camera_follows_player:
	# 	camera._dont_rotate = true
	# 	camera_pivot.player_to_follow = get_node("1")
	# 	camera_pivot.follow_player = true
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


# --- MOD EXPORTING STUFF ---

## Returns the name the stage will use internally to load files. 
## For example, if the stage is saved in levels/greenhill/greenhill.tscn, the internal name will be greenhill
func get_stage_internal_name():
	var file_path_split = stage_info.resource_path.split("/")
	var file_name = file_path_split[-1] # Last part of the path, the file name
	return file_name.replace(".tres", "")


func get_file_list(folder_path):
	var file_paths: Array[String]
	var dir =  DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + folder_path + "/" + file_name)
				file_paths.append_array(get_file_list(folder_path + "/" + file_name))
			else:
				#print("Found file: " + folder_path + "/" + file_name)
				file_paths.append(folder_path + "/" + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return file_paths


func do_export_as_mod_pck():
	var internal_name = get_stage_internal_name()
	print("Exporting stage %s as mod..." % internal_name)
	var folder_path = "res://levels/%s" % internal_name
	# Create the folder to export mod if it doesn't exist
	DirAccess.make_dir_recursive_absolute("res://mod_export")
	# Create a PCKPacker instance and add all the stage files to the Mod PCK
	var packer = PCKPacker.new()
	packer.pck_start("res://mod_export/%s.pck" % internal_name)
	for file_path in get_file_list(folder_path):
		print("Adding file %s to mod PCK" % file_path)
		packer.add_file(file_path, file_path)
	var err = packer.flush(true)
	if err != OK:
		print("Failed to save mod PCK :(")
	
	