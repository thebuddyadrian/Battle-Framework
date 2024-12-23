extends Control

enum MODE {STORY, BATTLE, OPTIONS}
const MODE_NAMES = ["Story Mode", "Battle Mode", "Options"]
#enum MODE {STORY, BATTLE, CHALLENGE, TRAINING, MINIGAMES, RECORD, OPTIONS}
#const MODE_NAMES = ["Story Mode", "Battle Mode", "Challenge Mode", "Training Mode", "Mini Games", "Battle Record", "Options"]
var selected_mode: MODE = MODE.STORY : set = change_mode
var current_sprite: Sprite2D
@onready var current_mode_label: Label = $CurrentMode
@onready var not_ready_yet: Label = $NotReadyYet
@onready var mode_sprites: Node2D = $ModeSprites


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
	var previous_mode: MODE = selected_mode
	var previous_sprite: Sprite2D = current_sprite
	selected_mode = p_mode
	if selected_mode < 0:
		selected_mode = MODE.size() - 1
	if selected_mode >= MODE.size():
		selected_mode = 0
	current_sprite = mode_sprites.get_child(selected_mode)
	if previous_sprite:
		var fade_out: Tween = get_tree().create_tween()
		previous_sprite.modulate.a = 1
		fade_out.tween_property(previous_sprite, "modulate:a", 0, 0.3)
		fade_out.play()
		await fade_out.finished
		previous_sprite.hide()
	current_sprite.show()
	current_sprite.modulate.a = 0
	var fade_in: Tween = get_tree().create_tween()
	fade_in.play()
	fade_in.tween_property(current_sprite, "modulate:a", 1, 0.3)
	#current_mode_label.text = "<--" + MODE_NAMES[selected_mode] + "-->"
	not_ready_yet.visible = (selected_mode != MODE.BATTLE)
