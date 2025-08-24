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
#use the level directory
var battle_stages: Dictionary = {
	"Emeraldbeach":"emeraldbeach", 
	"Amysroom":"amysroom", 
	"Battlehwy":"battlehwy", 
	"Chaoruins":"chaoruins", 
	"Hologram":"chaoruins", 
	"Holysummit":"holysummit", 
	"Greenhill":"greenhill"
}

var modded_battle_stages:Dictionary = {
	
}

# Load modded characters into the "characters" array In Mod_Character_Loader.gd
func _ready() -> void:
	#Moved level mod loading to Mod_Level_Loader.gd
	
	pass
	
