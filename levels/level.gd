## A base class for all levels.
extends Node3D
class_name Level

@export var music  : AudioStream

var audiostreamplayer = AudioStreamPlayer.new()

func _ready() -> void:
	#audiostreamplayer.stream = music
	#add_child(audiostreamplayer)
	#if audiostreamplayer.stream != null && !audiostreamplayer.playing:
		#audiostreamplayer.play()
	MusicPlayer.play_track(preload("res://assets/Audio/BGM/04. Emerald Beach.mp3"))
