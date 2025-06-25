extends Control

var opt = 0

@onready var it1 = $Continue/AnimationPlayer
@onready var it2 = $Options/AnimationPlayer
@onready var it3 = $Quit/AnimationPlayer

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("up1"):
		opt -=1
		if opt < 0:
			opt = 2
		
	if Input.is_action_just_pressed("down1"):
		opt +=1
		if opt > 2:
			opt = 0
		
	match(opt):
		0:
			it1.play("Highlighted")
			it2.play("RESET")
			it3.play("RESET")
			if Input.is_action_just_pressed("jump1"):
				queue_free()
		1:
			it1.play("RESET")
			it2.play("Highlighted")
			it3.play("RESET")
			
		2:
			it1.play("RESET")
			it2.play("RESET")
			it3.play("Highlighted")
			if Input.is_action_just_pressed("jump1"):
				get_tree().change_scene_to_file("res://menus/mode_select.tscn")
