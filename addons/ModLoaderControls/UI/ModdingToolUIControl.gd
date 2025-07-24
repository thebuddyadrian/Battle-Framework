@tool
extends Control

var Control_Items:Dictionary

var CurrentModFile:Array = ["ModTest"]
var CurrentSubModName = "Character1"

var FileItems:Dictionary = {}

@export var ModFileList:ItemList
@export var SubFileList:ItemList
@export var ModCreationButton:Control
@export var SubCreationButton:Control

@export var ExportType:OptionButton

@export var ExportTypeFiles:Array[Resource] = []

@export var ExportButton:Button

var DefaultModFile:Dictionary = preload("res://ModLoader/Defaults/DefaultMod.json").data
var DefaultSubFile:Dictionary = preload("res://ModLoader/Defaults/DefaultSubMod.json").data
var ModDirectory:String = ""

var CurrentSubName:String = ""
var CurrentModName:String = ""

var NewFileInfo = ExportTypeFiles[ExportType.selected].data

func _enter_tree() -> void:
	ItemTypeSelected(0)
	
	ExportType.clear()
	for _Ex in ExportTypeFiles:
		ExportType.add_item(_Ex.data["Type"])
	
	var PrefDetails:Dictionary = Mod_Loader_Preferences.LoadModLoaderPreferences()
	ModDirectory = PrefDetails["mods-folder"]
	UpdateModRefs()
	
	ModFileList.select(0)
	SubFileList.select(0)
	
	ModSelectedF(0)
	SubSelectedF(0)
	
	ExportButton.disabled = true
	
	pass
	
func UpdateModRefs() -> void:
	FileItems = Mod_Loader_Base.GetAllModFiles(ModDirectory, true)
	
	ModFileList.clear()
	SubFileList.clear()
	for _item in FileItems:
		ModFileList.add_item(_item)
		for _sub in FileItems[_item]:
			SubFileList.add_item(_sub.get_file().get_basename())
			
	SubFileList.add_item("New")
	ModFileList.add_item("New")
	
	ModCreationButton.visible = false
	SubCreationButton.visible = false
	

func ModSelectedF(index: int) -> void:
	ModCreationButton.visible = index >= ModFileList.item_count - 1
	if(index < ModFileList.item_count-1):
		CurrentModName = ModFileList.get_item_text(index)
		UpdateSubMenuToMod(ModFileList.get_item_text(index))
	else:
		CurrentModName = ""
		SubFileList.clear()
	ExportButton.disabled = CurrentSubName == "" || CurrentModName == ""
	pass # Replace with function body.

func UpdateSubMenuToMod(_current = "") -> void:
	SubFileList.clear()
	if(_current != ""):
		for _sub in FileItems[_current]:
			SubFileList.add_item(_sub.get_file().get_basename())
	SubFileList.add_item("New")

func SubSelectedF(index: int) -> void:
	SubCreationButton.visible = index >= SubFileList.item_count - 1
	if(index < SubFileList.item_count-1):
		CurrentSubName = SubFileList.get_item_text(index)
	else:
		CurrentSubName = ""
	ExportButton.disabled = CurrentSubName == "" || CurrentModName == ""
	pass # Replace with function body.


func ModFolderCreate() -> void:
	var CurrentTextM = $Panel/BaseArea/HSplitContainer/ModContainer/ModCreationMenu/TextEdit
	if(CurrentTextM.text != "" && CurrentTextM.text != "NULL"):
		var ModDir = ModDirectory + "/" + CurrentTextM.text
		Mod_Loader_Base.HasOrCreateFolder(ModDir)
		var UpFile = DefaultModFile.duplicate()
		UpFile["Name"] = CurrentTextM.text
		Mod_Loader_Base.HasOrCreateFile(ModDir+"/"+CurrentTextM.text+".json",JSON.stringify(UpFile))
		UpdateModRefs()
		UpdateSubMenuToMod(ModFileList.get_item_text(0))
	pass # Replace with function body.

func SubFolderCreate() -> void:
	var CurrentTextM = $Panel/BaseArea/HSplitContainer/SubContainer/SubCreationMenu/TextEdit
	if(CurrentTextM.text != "" && CurrentTextM.text != "NULL"):
		var SubDir = ModDirectory + "/" + CurrentModName + "/" + CurrentTextM.text
		Mod_Loader_Base.HasOrCreateFolder(SubDir)
		var SubFile = DefaultSubFile.duplicate()
		SubFile["Name"] = CurrentTextM.text
		Mod_Loader_Base.HasOrCreateFile(SubDir+"/"+CurrentTextM.text+".json",JSON.stringify(SubFile))
		UpdateModRefs()
	pass # Replace with function body.
	
func ExportAsset() -> void: # Export button function
	if(CurrentSubName == "" || CurrentModName == ""): return
	var SubDir = ModDirectory + "/" + CurrentModName + "/" + CurrentSubName + "/" + CurrentSubName +".json"
	var TmFile = Mod_Loader_Base.HasOrCreateFile(SubDir,"{}")
	if(TmFile):
		var FileDetails = Mod_Loader_Base.ReadFullJsonData(SubDir)
		for _v in FileDetails.keys():
			if(NewFileInfo.has(_v)): NewFileInfo[_v] = FileDetails[_v]
		NewFileInfo["Type"] = ExportType.get_item_text(ExportType.selected)
		Mod_Loader_Base.WriteFullJsonData(SubDir,NewFileInfo)
		#Export scene to file set local stuff simaltaniously
		var CurrentExportScene = EditorInterface.get_edited_scene_root()
		Mod_Exporter_Tool.ExportFullSceneToModAsset(CurrentExportScene,SubDir.get_basename()+".tscn")
		
		pass


func ItemTypeSelected(index: int) -> void:
	var FileContentSection = $"Panel/BaseArea/HSplitContainer/TabContainer/Item Info/Panel/VBoxContainer/FileScroll/FileContents"
	NewFileInfo = ExportTypeFiles[index].data
	FileContentSection.text = JSON.stringify(NewFileInfo, "\t")
	pass # Replace with function body.
