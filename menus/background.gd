@tool
extends Node2D


func _ready() -> void:
	$Sprite2D.region_rect.position.y = 0


func _process(delta: float) -> void:
	$Sprite2D.region_rect.position.y -= delta * 60
