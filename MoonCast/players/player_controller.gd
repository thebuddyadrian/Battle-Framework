## Responsible for handling input.
extends Node
class_name PlayerController


@export var character: BattleCharacter = null

var screen_res:= true

var keys_down := []
#func _input(_event):
	#if !is_instance_valid(character): return
#
	## The jump input
	#if Input.is_action_just_pressed("jump"): character.jump()
	## The attack input
	#if Input.is_action_just_pressed("attack"): character.attack()
	#var new_run_velocity = Input.get_vector("move_left", "move_right", "move_down", "move_up")
#
	#character.run_velocity=new_run_velocity
#
	#if Input.is_action_just_pressed("pause"): screen_res = not screen_res
	#if screen_res:
		#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	#else:
		#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
#
	#if Input.is_action_pressed("block"): character.block(true)
	#if Input.is_action_just_released("block"): character.block(false)
#
	#return
