extends Node


func play_sound_effect(name: String, stream: AudioStream, bus: String, position: Vector3 = Vector3.INF, volume_db: float = 0.0, stop_same_name: bool = true) -> void:
	var audio_stream_player

	# If position is specified, use AudioStreamPlayer 3D, otherwise use normal AudioStreamPlayer
	if position.is_finite():
		audio_stream_player = AudioStreamPlayer3D.new()
		audio_stream_player.position = position
	else:
		audio_stream_player = AudioStreamPlayer.new()

	# Stop and restart sound effect if its already playing
	if get_tree().current_scene.has_node(name) and stop_same_name:
		get_tree().current_scene.get_node(name).stop()
		get_tree().current_scene.get_node(name).play()
		return

	audio_stream_player.name = name
	audio_stream_player.stream = stream
	audio_stream_player.volume_db = volume_db
	audio_stream_player.bus = bus
	get_tree().current_scene.add_child(audio_stream_player)
	audio_stream_player.play()
	audio_stream_player.connect("finished", audio_stream_player.queue_free)


func stop_sound(sound_name: String):
	get_node(sound_name).queue_free()
