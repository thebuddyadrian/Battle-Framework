extends Control

const MIN_PLAYERS = 2
const MAX_PLAYERS = 4

@onready var title_label: Label = $TitleLabel
@onready var ok_button: Button = %OKButton
@onready var human_spin_box: SpinBox = %HumanSpinBox
@onready var cpu_spin_box: SpinBox = %CPUSpinBox
@onready var multi_window: CheckBox = %MultiWindow


func _ready() -> void:
	MusicPlayer.play_track(MusicPlayer.CHALLENGE_BATTLE_MODE)
	multi_window.button_pressed = !MatchSetup.single_window
	# Prevent focusing away from spin box when using left and right to set value
	human_spin_box.get_line_edit().focus_neighbor_left = "."
	human_spin_box.get_line_edit().focus_neighbor_right = "."
	cpu_spin_box.get_line_edit().focus_neighbor_left = "."
	cpu_spin_box.get_line_edit().focus_neighbor_right = "."
	human_spin_box.get_line_edit().grab_focus()


func _process(delta: float) -> void:
	var cpu_players: int = cpu_spin_box.value
	var human_players: int = human_spin_box.value
	var total_players: int = cpu_players + human_players
	ok_button.disabled = (total_players < MIN_PLAYERS)

	var focused: Control = get_viewport().gui_get_focus_owner()
	# Use left/right to set spin box values
	if focused == human_spin_box.get_line_edit():
		if Input.is_action_just_pressed("ui_left"):
			human_spin_box.value -= human_spin_box.step
		if Input.is_action_just_pressed("ui_right"):
			human_spin_box.value += human_spin_box.step
		# A hack to allow navigating away from human spin box when its selected
		if Input.is_action_just_pressed("ui_down"):
			multi_window.grab_focus()
	if focused == cpu_spin_box.get_line_edit():
		if Input.is_action_just_pressed("ui_left"):
			cpu_spin_box.value -= cpu_spin_box.step
		if Input.is_action_just_pressed("ui_right"):
			cpu_spin_box.value += cpu_spin_box.step


func _on_human_spin_box_value_changed(value: float) -> void:
	cpu_spin_box.max_value = MAX_PLAYERS - value


func _on_cpu_spin_box_value_changed(value: float) -> void:
	human_spin_box.max_value = MAX_PLAYERS - value


func _on_ok_button_pressed() -> void:
	var cpu_players: int = cpu_spin_box.value
	var human_players: int = human_spin_box.value
	var total_players: int = cpu_players + human_players
	MatchSetup.cpu_players = cpu_players
	MatchSetup.human_players = human_players
	MatchSetup.single_window = !multi_window.button_pressed
	SceneChanger.change_scene_to_file("res://menus/character_select/character_select.tscn")


func _on_change_controls_button_pressed() -> void:
	SceneChanger.change_scene_to_file("res://menus/controls_settings/controls_settings_menu.tscn")
