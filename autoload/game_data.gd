extends Node

var _character_info_dict: Dictionary[String, CharacterInfo]

var characters: Array[String] = [
	"sonic", 
	"tails", 
	"knuckles", 
	"shadow",
	# "kid_goku",
	#"rouge",
	#"amy",
	#"cream",
	#"emerl"
]

var battle_stages: Array[String] = [
	"emeraldbeach", 
	"amysroom", 
	"battlehwy", 
	"chaoruins",
	"hologram",
	"holysummit",
	"greenhill"
]

var modded_battle_stages: Array[String]


func _init() -> void:
	# Preload all CharacterInfo resources
	for character in characters:
		_character_info_dict[character] = load("res://characters/%s/%s.tres" % [character, character])


func _ready() -> void:
	# Load modded stages
	var game_folder = OS.get_executable_path()
	game_folder = game_folder.trim_suffix(game_folder.split("/")[-1])
	print("Game folder is at: " + game_folder)
	var stage_mods_folder = game_folder + "mods/stages"
	var dir = DirAccess.open(stage_mods_folder)
	if dir:
		print("Opened folder " + stage_mods_folder)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				if file_name.ends_with(".pck"):
					print("Found stage mod PCK: " + stage_mods_folder + file_name)
					var success = ProjectSettings.load_resource_pack("res://mods/stages/" + file_name)
					if success:
						print("Successfully loaded stage mod " + file_name)
						var stage_name = file_name.trim_suffix(".pck")
						# Add stage to "modded_battle_stages" array
						modded_battle_stages.append(stage_name)
					else:
						print("Could not load stage mod " + file_name)
			file_name = dir.get_next()
	else:
		print("Failed to open " + stage_mods_folder)


func get_character_info(character_name: String):
	assert(_character_info_dict.has(character_name), "Cannot find CharacterInfo for %s" % character_name)
	return _character_info_dict[character_name]
