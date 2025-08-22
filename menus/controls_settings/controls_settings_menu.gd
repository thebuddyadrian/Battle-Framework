extends Control
@onready var tab_container: TabContainer = $TabContainer


func _init() -> void:
	ControlsSettings.load_controls()


func _on_exit_button_pressed() -> void:
	for controls_setup_player in $TabContainer.get_children():
		controls_setup_player.apply_to_input_map()
	SceneChanger.change_scene_to_file("res://menus/player_setup.tscn")
	ControlsSettings.save_controls()


func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	for controls_setup_player in $TabContainer.get_children():
		controls_setup_player.initialize()