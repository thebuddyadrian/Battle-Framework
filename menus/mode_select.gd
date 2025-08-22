extends Control

enum MODE {STORY, BATTLE, CHALLENGE, TRAINING, MINIGAMES, RECORD, OPTIONS}
const MODE_NAMES = ["Story Mode", "Battle Mode", "Challenge Mode", "Training Mode", "Mini Games", "Battle Record", "Options"]
const ARROW_SCALE_DEFAULT: Vector2 = Vector2(1, 1)
var selected_mode: MODE = MODE.STORY : set = change_mode
var current_sprite: Sprite2D
@onready var current_mode_label: Label = $CurrentMode
@onready var not_ready_yet: Label = $NotReadyYet
@onready var mode_sprites: Node2D = $ModeSprites
@onready var arrow_left: Sprite2D = $ArrowLeft
@onready var arrow_right: Sprite2D = $ArrowRight
@onready var flame_logo: AnimatedSprite2D = $FlameLogo
@onready var mode_change_sound: AudioStreamPlayer = $ModeChangeSound


func _ready() -> void:
	# The game might have been changed to disable embedding subwindows in-game, this will change it back
	get_viewport().gui_embed_subwindows = true
	ControlsSettings.load_controls()
	change_mode(selected_mode)
	flame_logo.play("default")
	MusicPlayer.play_track(MusicPlayer.MAIN_MENU)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		selected_mode -= 1
		arrow_animation(arrow_left)
		mode_change_sound.play()
	if Input.is_action_just_pressed("ui_right"):
		selected_mode += 1
		arrow_animation(arrow_right)
		mode_change_sound.play()
		
	if Input.is_action_just_pressed("ui_accept"):
		_next_menu()
		


func _next_menu():
	if selected_mode == MODE.BATTLE:
		SceneChanger.change_scene_to_file("res://menus/player_setup.tscn")


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
		fade_out.tween_property(previous_sprite, "modulate:a", 0, 0.2)
		fade_out.play()
		await fade_out.finished
		previous_sprite.hide()
	current_sprite.show()
	current_sprite.modulate.a = 0
	var fade_in: Tween = get_tree().create_tween()
	fade_in.play()
	fade_in.tween_property(current_sprite, "modulate:a", 1, 0.2)
	#current_mode_label.text = "<--" + MODE_NAMES[selected_mode] + "-->"
	not_ready_yet.visible = (selected_mode != MODE.BATTLE)


func arrow_animation(arrow_node: Sprite2D):
	var tween: Tween = get_tree().create_tween()
	arrow_node.scale = ARROW_SCALE_DEFAULT
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(arrow_node, "scale", ARROW_SCALE_DEFAULT * 1.3, 0.06)
	tween.play()
	await tween.finished
	tween.stop()
	tween.tween_property(arrow_node, "scale", ARROW_SCALE_DEFAULT, 0.06)
	tween.play()
