extends Control

var LastSubMenu:Node = null
var CurrentMenu:Node = null

func _ready() -> void:
	#Disable Menus
	for _C in $Menus.get_children():
		_C.visible = false
	
	SelectMenu("MenuSelect")
	
		
	pass
	
func _process(delta: float) -> void:
	pass
	
func SelectMenu(_Option:String = "MenuSelect") -> void:
	if(CurrentMenu != null):
		if(CurrentMenu.name == _Option): return
		if(CurrentMenu.has_node("AnimationPlayer")):
			CurrentMenu.get_node("AnimationPlayer").play("Close")
		else:
			CurrentMenu.visible = false
	LastSubMenu = CurrentMenu
	
	var NewOption = $Menus.get_node(_Option)
	if(NewOption.has_node("AnimationPlayer")):
		NewOption.get_node("AnimationPlayer").play("Open")
		
	NewOption.visible = true
	CurrentMenu = NewOption
	
func BackToMainMenu() -> void:
	SceneChanger.change_scene_to_file("res://menus/mode_select.tscn")
