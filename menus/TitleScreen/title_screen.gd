extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Opening")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#$AnimationPlayer.play("Opening")
	pass
	
func animation_done_transition() -> void:
	SceneChanger.change_scene_to_file("res://menus/mode_select.tscn")
	pass
