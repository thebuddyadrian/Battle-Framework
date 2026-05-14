extends Control
@onready var tab_container: TabContainer = $TabContainer


func _ready() -> void:
	ControlsSettings.load_all_button_layouts()
	ControlsSettings.load_controls_settings()


func _on_exit_button_pressed() -> void:
	for controls_setup_player in $TabContainer.get_children():
		controls_setup_player.apply_to_controls_settings()
	SceneChanger.change_scene_to_file("res://menus/player_setup.tscn")
	ControlsSettings.save_controls_settings()
	ControlsSettings.save_all_button_layouts()
