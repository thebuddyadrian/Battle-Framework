extends Control
@onready var tab_container: TabContainer = $TabContainer


func _on_exit_button_pressed() -> void:
	for controls_setup_player in $TabContainer.get_children():
		controls_setup_player.apply_to_input_map()
	SceneChanger.change_scene_to_file("res://menus/player_setup.tscn")
	Globals.save_controls()
