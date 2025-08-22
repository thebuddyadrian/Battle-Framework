extends Control

var LastSubMenu:Node = null

func _ready() -> void:
	#Disable Menus
	for _C in $Menus.get_children():
		_C.visible = false
	
	SelectMenu("MenuSelect")
	
		
	pass
	
func _process(delta: float) -> void:
	pass
	
func SelectMenu(_Option:String = "MenuSelect") -> void:
	
	if(LastSubMenu != null):
		LastSubMenu.visible = false
	
	var NewOption = $Menus.get_node(_Option)
	NewOption.visible = true
	LastSubMenu = NewOption
	
func BackToMainMenu() -> void:
	SceneChanger.change_scene_to_file("res://menus/mode_select.tscn")
