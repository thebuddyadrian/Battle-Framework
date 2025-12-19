extends Control

const MAX_PLAYERS = 4

@onready var title_label: Label = $TitleLabel
@onready var ok_label: Label = $OKLabel
@onready var ok_button: Button = $OKButton
@onready var human_spin_box: SpinBox = $GridContainer/HumanSpinBox
@onready var cpu_spin_box: SpinBox = $GridContainer/CPUSpinBox
@onready var cpu_label : Label = $GridContainer/CPULabel
#@onready var stage_option_button: OptionButton = $GridContainer/StageOptionButton


func _ready() -> void:
	MusicPlayer.play_track(MusicPlayer.CHALLENGE_BATTLE_MODE)


func _process(delta: float) -> void:
	var cpu_players: int = cpu_spin_box.value
	var human_players: int = human_spin_box.value
	var total_players: int = cpu_players + human_players
	ok_label.visible = total_players >= 2
	#ok_button.visible = total_players >= 2
	#cpu_spin_box.visible = human_players == 1
	#cpu_label.visible = human_players == 1
	if Input.is_action_just_pressed("ui_accept") and total_players >= 2:
		SceneChanger.change_scene_to_file("res://menus/character_select/character_select.tscn")
		MatchSetup.cpu_players = cpu_players
		MatchSetup.human_players = human_players


func _on_human_spin_box_value_changed(value: float) -> void:
	cpu_spin_box.max_value = MAX_PLAYERS - value


func _on_cpu_spin_box_value_changed(value: float) -> void:
	human_spin_box.max_value = MAX_PLAYERS - value


func _on_ok_button_pressed() -> void:
	SceneChanger.change_scene_to_file("res://menus/character_select/character_select.tscn")
	var cpu_players: int = cpu_spin_box.value
	var human_players: int = human_spin_box.value
	MatchSetup.cpu_players = cpu_players
	MatchSetup.human_players = human_players


func _on_change_controls_button_pressed() -> void:
	SceneChanger.change_scene_to_file("res://menus/controls_settings/controls_settings_menu.tscn")
