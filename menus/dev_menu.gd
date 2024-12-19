extends CanvasLayer

@onready var scene_select_window:FileDialog = $FileDialog

func finalize_switch_scene(path:String) -> void:
	get_tree().change_scene_to_file(path)
	scene_select_window.hide()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _input(event: InputEvent) -> void:
	if Game.debug_mode and event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		visible = not visible #toggle visibility

func _on_switch_scene_pressed() -> void:
	scene_select_window.show()
	if not scene_select_window.is_connected(&"file_selected", finalize_switch_scene):
		scene_select_window.connect(&"file_selected", finalize_switch_scene, CONNECT_ONE_SHOT)

func _on_reboot_pressed() -> void:
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().quit()
