@tool
extends EditorPlugin

var BaseUI = preload("res://addons/ModLoaderControls/UI/BaseModDockUI.tscn")
var BaseModDock:Control

func _enter_tree() -> void:
	BaseModDock = BaseUI.instantiate()
	add_control_to_bottom_panel(BaseModDock,"Modding Tools")
	pass


func _exit_tree() -> void:
	remove_control_from_bottom_panel(BaseModDock)
	# Clean-up of the plugin goes here.
	pass
