@tool
extends Node2D


func _process(delta: float) -> void:
	$Sprite2D.region_rect.position.y -= delta * 60
