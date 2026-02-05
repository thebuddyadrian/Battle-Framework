extends Node3D
class_name MatchScene

const CAMERA_ROOT = preload("res://components/camera_root/camera_root.tscn")
const PLAYER_WINDOW = preload("res://components/player_window/player_window.tscn")
const PLAYER_HUD = preload("res://components/player_hud/player_hud.tscn")
const PAUSE_MENU = preload("uid://cifkfj62fb1ho")


@export var test_characters: Array[String] = ["sonic", "tails"]
@export var test_stage: String # TO-DO, not in use yet

var stage: Level
var camera_pivots: Dictionary[int, Node3D]
var cameras: Dictionary[int, Camera3D]


func _ready() -> void:
	if MatchSetup.single_window:
		# Double the content size to allow split screen
		get_window().content_scale_size = Vector2i(240*2, 160*2)
	else:
		# Make sure subwindows aren't embedded, or else multiple windows wont spawn
		get_viewport().gui_embed_subwindows = false
	
	ControlsSettings.load_controls()
	Game.match_results.clear()
	initialize_match()

	

func initialize_match():
	# If no characters have been selected, use test characters
	if MatchSetup.character_choices.is_empty():
		MatchSetup.human_players = test_characters.size()
		for i in range(test_characters.size()):
			MatchSetup.character_choices[i + 1] = test_characters[i]
			MatchSetup.current_stage_index = 0
			MatchSetup.stage_list = [test_stage]

	# Load Stage
	var current_stage: String = MatchSetup.stage_list[MatchSetup.current_stage_index]
	print("Loading stage \"%s\"" % current_stage)
	var stage_scene: PackedScene = load("res://levels/%s/%s.tscn" % [current_stage, current_stage])
	stage = stage_scene.instantiate()
	add_child(stage)

	# Get music track
	if stage and stage.stage_info:
		if stage.stage_info.music_file_path:
			print("Loading music track %s" % stage.stage_info.music_file_path)
			MusicPlayer.play_track(load(stage.stage_info.music_file_path))

	# Spawn cameras
	for i in range(MatchSetup.get_total_players()):
		var camera_root = CAMERA_ROOT.instantiate()
		if MatchSetup.single_window:
			var viewport = SubViewport.new()
			viewport.size = Vector2(240,160)
			viewport.audio_listener_enable_3d = true
			var subviewport_container = get_node("%SubViewportContainer" + str(i + 1))
			subviewport_container.add_child(viewport)
			viewport.add_child(camera_root)
		else:
			# For players 2-4, spawn a separate window
			if i > 0 or MatchSetup.single_window:
				var window = PLAYER_WINDOW.instantiate()
				stage.camera_root_parent.add_child(window)
				window.add_child(camera_root)
			else:
				stage.camera_root_parent.add_child(camera_root)
		camera_root.name = "CameraRoot" + str(i + 1)
		var camera_pivot = camera_root.get_node("Pivot")
		var camera = camera_root.get_node("Pivot/Camera")
		camera_pivots[i] = camera_pivot
		cameras[i] = camera

	# Spawn characters
	assert(stage.player_spawn_1, "No spawn position has been placed for player 1")
	assert(stage.player_spawn_2, "No spawn position has been placed for player 2")
	assert(stage.player_spawn_3, "No spawn position has been placed for player 3")
	assert(stage.player_spawn_4, "No spawn position has been placed for player 4")
	for i in range(MatchSetup.get_total_players()):
		var character = MatchSetup.character_choices[i + 1]
		var player: BattleCharacter = ResourceLoader.load("res://characters/%s/%s.tscn" % [character, character]).instantiate()
		# Get the player_spawn_<x> variable, which holds a node reference to the spawn position
		var spawn_position: Node3D = stage.get("player_spawn_%s" % str(i + 1))
		player.global_position = spawn_position.global_position
		player.camera = camera_pivots[i]
		player.scale = Vector3(4, 4, 4)
		player.player_id = i + 1
		cameras[i].player_id_to_track = i + 1
		player.name = str(player.player_id)
		player.char_name = character
		player.kod.connect(_on_player_kod)
		spawn_position.get_parent().add_child(player)

		# Spawn HUD
		var player_hud = PLAYER_HUD.instantiate()
		cameras[i].add_child(player_hud)
		player_hud.track_player(player)


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


func _get_alive_player_count():
	var count: int = 0
	for player in get_tree().get_nodes_in_group("characters"):
		if player is BattleCharacter:
			if player.current_stocks > 0:
				count += 1
	return count


func _on_player_kod(player: BattleCharacter):
	# Your placement depends on how many players were alive when you got KO'd
	Game.match_results[player.player_id] = _get_alive_player_count() + 1
	if _get_alive_player_count() <= 1:
		# Add the winner player
		for remaining_player in get_tree().get_nodes_in_group("characters"):
			if remaining_player is BattleCharacter:
				if remaining_player.current_stocks > 0:
					Game.match_results[remaining_player.player_id] = 1
		_go_to_results_screen()


func _go_to_results_screen():
	SceneChanger.change_scene_to_file("res://menus/results_screen/results_screen.tscn")
