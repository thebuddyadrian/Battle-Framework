extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _input(event: InputEvent) -> void:
	if Game.debug_mode and event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		visible = not visible #toggle visibility

func _on_switch_scene_pressed() -> void:
	#TODO: Menu here
	pass # Replace with function body.

func _on_reboot_pressed() -> void:
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().quit()
