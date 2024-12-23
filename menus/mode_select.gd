extends Control

enum MODE {STORY, BATTLE, CHALLENGE, TRAINING, MINIGAMES, RECORD, OPTIONS}
const MODE_NAMES = ["Story Mode", "Battle Mode", "Challenge Mode", "Training Mode", "Mini Games", "Battle Record", "Options"]
var selected_mode: MODE = MODE.STORY : set = change_mode

@onready var current_mode_label: Label = $CurrentMode
@onready var not_ready_yet: Label = $NotReadyYet


func _ready() -> void:
	change_mode(selected_mode)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		selected_mode -= 1
	if Input.is_action_just_pressed("ui_right"):
		selected_mode += 1
	if Input.is_action_just_pressed("ui_accept"):
		_next_menu()


func _next_menu():
	if selected_mode == MODE.BATTLE:
		get_tree().change_scene_to_file("res://menus/player_setup.tscn")


func change_mode(p_mode):
	selected_mode = p_mode
	if selected_mode < 0:
		selected_mode = MODE.size() - 1
	if selected_mode >= MODE.size():
		selected_mode = 0
	current_mode_label.text = "<--" + MODE_NAMES[selected_mode] + "-->"
	not_ready_yet.visible = (selected_mode != MODE.BATTLE)
