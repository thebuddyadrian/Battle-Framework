@tool
extends Node
class_name Mod_Loader_Preferences

static var ModPreferencesDirectory = "user://mods/preferences"
static var LoadedModPrefs:Dictionary = {}
static var DefaultPreferences = (preload("res://ModLoader/Defaults/DefaultPreferences.json").data)

static func LoadModLoaderPreferences() -> Dictionary:
	var ModPrefFileDir = ModPreferencesDirectory+"/ModLoaderPrefs.json"
	Mod_Loader_Base.HasOrCreateFolder(ModPreferencesDirectory)
	if(Mod_Loader_Base.HasOrCreateFile(ModPrefFileDir,JSON.stringify(DefaultPreferences,"\t"))):
		LoadedModPrefs = Mod_Loader_Base.ReadFullJsonData(ModPrefFileDir)
	else:
		var FullDictJson = DefaultPreferences
		LoadedModPrefs = FullDictJson
		
	return LoadedModPrefs
