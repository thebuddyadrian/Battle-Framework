extends Control

@onready var pixelate: AnimationPlayer = $pixelate
@onready var characters: TextureRect = $Characters


func character_change():
	pixelate.play("pixelate")
