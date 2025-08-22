extends Control
class_name Mod_Menu_Base

@export var BaseModEntry = preload("res://ModLoader/UI/Mod_Menu_Single_ModEntry.tscn")
var SubMenuOpen:bool = false

func _ready() -> void:
	UpdateModEntries()
	
	pass
	
func UpdateModEntries() -> void:
	for _child in $ModMenuArea/ScrollContainer/VBoxContainer.get_children():
		_child.queue_free()
	$ModMenuArea/NoMods.visible = ModLoaderMaster.ModsByDir.size() <= 0
	for _mod in ModLoaderMaster.ModsByDir:
		var CurrentModEntry = BaseModEntry.instantiate()
		CurrentModEntry.ModName = _mod.get_file().get_basename()
		CurrentModEntry.get_node("ModTab/Label").text = _mod.get_file().get_basename()
		$ModMenuArea/ScrollContainer/VBoxContainer.add_child(CurrentModEntry)
		CurrentModEntry.UpdateSubEntries(ModLoaderMaster.ModsByDir[_mod])

	
func _process(delta: float) -> void:
	pass
