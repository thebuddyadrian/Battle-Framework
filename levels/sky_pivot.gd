extends Node3D

func _process(delta: float) -> void:
	rotation.y = get_parent().match_scene.camera_pivots[0].rotation.y
