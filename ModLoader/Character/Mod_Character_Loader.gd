extends Node
class_name Mod_Character_Loader

static func LoadCharactersFromCatagoryList(_dict:Dictionary) -> void:
	#Clear
	Lists.modded_characters = []
	Lists.modded_char_display_names = {}
	Lists.modded_character_dir = {}
	Lists.modded_Char_Portrait_texture.clear()
	Lists.modded_Char_Portrait_texture = {}
	
	#New
	for _char in _dict["Character"]:
		var _char_file = Mod_Loader_Base.GetQuickJson(_char)
		var CharacterData = Mod_Loader_Base.ReadFullJsonData(_char_file)
		Lists.modded_character_dir[CharacterData["Name"]] = _char_file.get_basename()+".tscn" # Get character file
		Lists.modded_characters.push_back(CharacterData["Name"])
		Lists.modded_char_display_names[CharacterData["Name"]] = CharacterData["Name"]
		#Add character select image
		if(CharacterData.has("Select-Image")):
			var I = Image.new()
			I.load(_char_file.get_base_dir()+"/"+CharacterData["Select-Image"])
			var IT:ImageTexture = ImageTexture.create_from_image(I)
			Lists.modded_Char_Portrait_texture[CharacterData["Name"]] = IT
		
	pass
