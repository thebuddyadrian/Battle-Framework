extends Control

const MAX_PLAYERS = 4

@onready var title_label: Label = $TitleLabel
@onready var ok_label: Label = $OKLabel
@onready var human_spin_box: SpinBox = $GridContainer/HumanSpinBox
@onready var cpu_spin_box: SpinBox = $GridContainer/CPUSpinBox


func _process(delta: float) -> void:
	var cpu_players: int = cpu_spin_box.value
	var human_players: int = human_spin_box.value
	var total_players: int = cpu_players + human_players
	ok_label.visible = total_players >= 2
	if Input.is_action_just_pressed("ui_accept") and total_players >= 2:
		get_tree().change_scene_to_file("res://menus/character_select/character_select.tscn")
		
		Game.cpu_players = cpu_players
		Game.human_players = human_players


func _on_human_spin_box_value_changed(value: float) -> void:
	cpu_spin_box.max_value = MAX_PLAYERS - value


func _on_cpu_spin_box_value_changed(value: float) -> void:
	human_spin_box.max_value = MAX_PLAYERS - value
