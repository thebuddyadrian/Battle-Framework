## A base class for all levels.
@tool
extends Node3D
class_name Level

const CAMERA_ROOT = preload("res://components/camera_root/camera_root.tscn")
const PLAYER_WINDOW = preload("res://components/player_window/player_window.tscn")
const PLAYER_HUD = preload("res://components/player_hud/player_hud.tscn")
const PAUSE_MENU = preload("uid://cifkfj62fb1ho")

@export var stage_info: StageInfo
@export var player_spawn_1: Node3D
@export var player_spawn_2: Node3D
@export var player_spawn_3: Node3D
@export var player_spawn_4: Node3D
@export var camera_follows_player: bool = false # For beat-em-up levels
@export var camera_root_parent: Node = self

@export_tool_button("Export as Mod PCK") var export_as_mod_pck = do_export_as_mod_pck

@onready var match_scene: MatchScene = get_parent()

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
	DirAccess.make_dir_recursive_absolute("res://mod_export/stages")
	# Create a PCKPacker instance and add all the stage files to the Mod PCK
	var packer = PCKPacker.new()
	packer.pck_start("res://mod_export/levels/%s.pck" % internal_name)
	for file_path in get_file_list(folder_path):
		print("Adding file %s to mod PCK" % file_path)
		packer.add_file(file_path, file_path)
	var err = packer.flush()
	if err != OK:
		print("Failed to save mod PCK :(")
	else:
		print("Mod export successful!")
	
