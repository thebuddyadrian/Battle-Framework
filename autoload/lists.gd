extends Node

var characters: Array[String] = [
	"sonic", "tails", "knuckles", "shadow", "kid_goku",#, "rouge", "amy", "cream", "emerl"
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

var battle_stages: Array[String] = [
	"emeraldbeach", "amysroom", "battlehwy", "chaoruins", "hologram", "holysummit", "greenhill"
]

# Load modded characters into the "characters" array
func _ready() -> void:
	pass
