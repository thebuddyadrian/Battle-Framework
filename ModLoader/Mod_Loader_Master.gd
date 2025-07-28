extends Node

static var ModFolderDirectory = "user://mods"
static var ModTempDirectory = "user://mods/tempresources"

static var ModsByDir:Dictionary = {}
static var ActiveModsDirs:Dictionary = {}
static var ActiveModCategories:Dictionary = {}

func _ready() -> void:
	#Load Mod Loader Preferences
	Mod_Loader_Preferences.LoadModLoaderPreferences()
	ModFolderDirectory = Mod_Loader_Preferences.LoadedModPrefs["mods-folder"]
	#Generate folders if they exist
	Mod_Loader_Base.HasOrCreateFolder(ModFolderDirectory)
	Mod_Loader_Base.HasOrCreateFolder(ModTempDirectory)
	
	ModsByDir = Mod_Loader_Base.GetAllModFiles(ModFolderDirectory)
	ActiveModsDirs = Mod_Loader_Base.CalculateActiveMods(
		ModsByDir,
		ModFolderDirectory,
		Mod_Loader_Preferences.LoadedModPrefs["disabled_mods"],
		Mod_Loader_Preferences.LoadedModPrefs["disabled_per_mods"]
	)
	#Always call for new mods
	Mod_Loader_Base.FixSelectedMods(ActiveModsDirs.values())
	ActiveModCategories = Mod_Loader_Base.CalculateModTypes(ActiveModsDirs, ModFolderDirectory)
	#Load Character listing from ActiveModCategories
	Mod_Character_Loader.LoadCharactersFromCatagoryList(ActiveModCategories)
	print("Temp Dict ",ActiveModCategories)
	
	pass
