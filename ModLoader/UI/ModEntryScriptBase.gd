extends VBoxContainer

@export var SubEntries:Array = []

var SubModEntryObject = preload("res://ModLoader/UI/Mod_Menu_Single_SubEntry.tscn")
var SubMenuOpen:bool = false
var ModName:String = "FFFFF"

func _ready() -> void:
	OpenSubMenu(false)
	
	pass
	
func UpdateSubEntries(_subs:Array) -> void:
	#UpdateChildren
	for _child in $SubContainer.get_children():
		_child.queue_free()
	for _sub in _subs:
		var SubEntry = SubModEntryObject.instantiate()
		SubEntry.get_node("SubModButton/ItemName").text = _sub.get_file().get_basename()
		$SubContainer.add_child(SubEntry)

		if(ModLoaderMaster.ModsIcons[ModName].has(_sub)):
			if(ModLoaderMaster.ModsIcons[ModName][_sub] != null):
				SubEntry.get_node("SubModButton/TextureRect").texture = ModLoaderMaster.ModsIcons[ModName][_sub]
		
	#UpdateMainIcon
	if(ModLoaderMaster.ModsIcons[ModName]["Icon"] != null):
		$ModTab/TextureRect.texture = ModLoaderMaster.ModsIcons[ModName]["Icon"]
		
	SubEntries = _subs

func OpenSubMenu(_o:bool) -> void:
	SubMenuOpen = _o
	$SubContainer.visible = SubMenuOpen

func ToggleMenu() -> void:
	OpenSubMenu(!SubMenuOpen)
