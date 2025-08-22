extends Node

var characters: Array[String] = [
	"sonic", "tails", "knuckles", "shadow",# "kid_goku", "rouge", "amy", "cream", "emerl"
]

var modded_characters: Array[String] = [
	
]

var character_display_names: Dictionary = {
	"sonic": "Sonic",
	"tails": "Tails",
	"knuckles": "Knuckles",
	"shadow": "Shadow",
	"rouge": "Rouge",
	"amy": "Amy",
	"cream": "Cream",
	"emerl": "Emerl",
	"kid_goku": "Kid Goku",
}

var Character_Portrait_texture: Dictionary ={
	"sonic": preload("res://characters/sonic/sprites/Sonic Portrait.png"),
	"tails": preload("res://characters/tails/sprites/Tails Portrait.png"),
	"knuckles": preload("res://characters/knuckles/sprites/Knuckles Portrait.png"),
	"shadow": preload("res://characters/shadow/sprites/Shadow Portrait.png")
}

var modded_char_display_names:Dictionary = {
	
}
#referenced for spawning characters from different Directories
var modded_character_dir:Dictionary = {
	
}

var modded_Char_Portrait_texture:Dictionary ={
	
}

var battle_stages: Array[String] = [
	"emeraldbeach", "amysroom", "battlehwy", "chaoruins", "hologram", "holysummit", "greenhill"
]

var modded_battle_stages: Array[String]

# Load modded characters into the "characters" array
func _ready() -> void:
	# Load Stage mods
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
						modded_battle_stages.append(stage_name)
					else:
						print("Could not load stage mod " + file_name)
			file_name = dir.get_next()
	else:
		print("Failed to open " + stage_mods_folder)
	
