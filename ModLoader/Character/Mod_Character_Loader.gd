extends Node
class_name Mod_Character_Loader

static func LoadCharactersFromCatagoryList(_dict:Dictionary) -> void:
	Lists.modded_characters = []
	Lists.modded_char_display_names = {}
	Lists.modded_character_dir = {}
	for _char in _dict["Character"]:
		var _char_file = Mod_Loader_Base.GetQuickJson(_char)
		var CharacterData = Mod_Loader_Base.ReadFullJsonData(_char_file)
		Lists.modded_character_dir[CharacterData["Name"]] = _char_file.get_basename()+".tscn" # Get character file
		Lists.modded_characters.push_back(CharacterData["Name"])
		Lists.modded_char_display_names[CharacterData["Name"]] = CharacterData["Name"]
	pass
