extends Control

var opt = 0
var player_id: int = 0

@onready var it1 = $Continue/AnimationPlayer
@onready var it2 = $Options/AnimationPlayer
@onready var it3 = $Quit/AnimationPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _physics_process(delta: float) -> void:
	if visible:
		if input("up", "just_pressed"):
			opt -=1
			if opt < 0:
				opt = 2
			
		if input("down", "just_pressed"):
			opt +=1
			if opt > 2:
				opt = 0
			
		match(opt):
			0:
				it1.play("Highlighted")
				it2.play("RESET")
				it3.play("RESET")
				if input("jump", "just_pressed"):
					get_tree().paused = false
					hide()
			1:
				it1.play("RESET")
				it2.play("Highlighted")
				it3.play("RESET")
			2:
				it1.play("RESET")
				it2.play("RESET")
				it3.play("Highlighted")
				if input("jump", "just_pressed"):
					get_tree().paused = false
					get_viewport().gui_embed_subwindows = false
					get_tree().change_scene_to_file("res://menus/mode_select.tscn")
	
		if input("pause", "just_pressed"):
			get_tree().paused = false
			hide()
	else:
		if input("pause", "just_pressed"):
			show()
			get_tree().paused = true


## Input helper function to get input for the current player
## In the future this will also retrieve inputs received over the network (for online play)
func input(action: StringName, type: String = "pressed") -> bool:
	var player_action = action + str(player_id)
	if !InputMap.has_action(player_action):
		push_error("Action %s doesn't exist" % player_action)
		return false
	if type == "pressed":
		return Input.is_action_pressed(player_action)
	if type == "just_pressed":
		return Input.is_action_just_pressed(player_action)
	if type == "just_released":
		return Input.is_action_just_released(player_action)
	return false
