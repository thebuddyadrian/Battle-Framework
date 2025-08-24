extends Node
class_name Mod_Level_Loader

static func LoadMapFromCatagoryList(_dict:Dictionary) -> void:
	#Clear
	Lists.modded_battle_stages = {}
	
	#New
	if(!_dict.has("Map")): return
	for _level in _dict["Map"]:
		var _level_file = Mod_Loader_Base.GetQuickJson(_level)
		var LevelData = Mod_Loader_Base.ReadFullJsonData(_level_file)
		Lists.modded_battle_stages[LevelData["Name"]] = _level.get_basename()+"/"+_level.get_file().get_basename()+".tscn"
		
	pass
