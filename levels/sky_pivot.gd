extends Node3D

func _process(delta: float) -> void:
	rotation.y = get_parent().camera_pivots[0].rotation.y
