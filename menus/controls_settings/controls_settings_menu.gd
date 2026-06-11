extends Control
@onready var tab_container: TabContainer = $TabContainer
@onready var instructions: Label = $Instructions

func _ready() -> void:
	ControlsSettings.load_all_button_layouts()
	ControlsSettings.load_controls_settings()
	for controls_setup_player in tab_container.get_children():
		controls_setup_player.started_listening.connect(_on_controls_setup_player_started_listening)
		controls_setup_player.stopped_listening.connect(_on_controls_setup_player_stopped_listening)


func _on_exit_button_pressed() -> void:
	for controls_setup_player in tab_container.get_children():
		controls_setup_player.apply_to_controls_settings()
	SceneChanger.change_scene_to_file("res://menus/player_setup.tscn")
	ControlsSettings.save_controls_settings()
	ControlsSettings.save_all_button_layouts()


func _on_controls_setup_player_started_listening() -> void:
	instructions.show()
	for i in range(tab_container.get_tab_count()):
		if i == tab_container.current_tab:
			continue
		tab_container.set_tab_disabled(i, true)

func _on_controls_setup_player_stopped_listening() -> void:
	instructions.hide()
	for i in range(tab_container.get_tab_count()):
		tab_container.set_tab_disabled(i, false)
