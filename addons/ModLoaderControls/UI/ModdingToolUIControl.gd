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

var ModFileContentSection
var ItemFileContentSection

var NewFileInfo = ExportTypeFiles[ExportType.selected].data
var NewModInfo = DefaultModFile.data

var QueuedFunctionToQ:String = ""

var PrefDetails:Dictionary

func _enter_tree() -> void:
	ItemTypeSelected(0)
	
	ExportType.clear()
	for _Ex in ExportTypeFiles:
		ExportType.add_item(_Ex.data["Type"])
	
	PrefDetails = Mod_Loader_Preferences.LoadModLoaderPreferences()
	ModDirectory = PrefDetails["mods-folder"]
	$Panel/BaseArea/HSplitContainer/TabContainer/Settings/LineEdit.text = ModDirectory
	UpdateModRefs()
	
	ModFileList.select(0)
	SubFileList.select(0)
	
	ModSelectedF(0)
	SubSelectedF(0)
	
	ExportButton.disabled = true
	
	pass
	
func UpdateModRefs() -> void:
	ItemFileContentSection = $"Panel/BaseArea/HSplitContainer/TabContainer/Item Info/Panel/VBoxContainer/FileScroll/FileContents"
	ModFileContentSection = $"Panel/BaseArea/HSplitContainer/TabContainer/Mod Info/Panel/VBoxContainer/FileScroll/FileContents"
	
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
	
	var CurrentFileDir = ModDirectory + "/" + CurrentModName + "/" + CurrentModName +".json"
	NewModInfo = Mod_Loader_Base.ReadFullJsonData(CurrentFileDir,true)
	ModFileContentSection.text = JSON.stringify(NewModInfo, "\t")
	
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
		
		var CurrentDir = ModDirectory + "/" + CurrentModName + "/" + CurrentSubName + "/" + CurrentSubName +".json"
		if(FileAccess.file_exists(CurrentDir)):
			var CurrentRef = Mod_Loader_Base.ReadFullJsonData(CurrentDir,true)
			SetTypeSelected(CurrentRef)
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
		Mod_Loader_Base.HasOrCreateFile(ModDir+"/_References.json",Mod_Exporter_Tool.DefaultReferenceFile)
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
		ItemTypeSelected(0)
	pass # Replace with function body.
	
func ExportAsset() -> void: # Export button function
	if(CurrentSubName == "" || CurrentModName == ""): return
	CallPopUp("ExportProcess")

func ExportProcess() -> void:
	var SubDir = ModDirectory + "/" + CurrentModName + "/" + CurrentSubName + "/" + CurrentSubName +".json"
	var TmFile = Mod_Loader_Base.HasOrCreateFile(SubDir,"{}")
	if(TmFile):
		#var FileDetails = Mod_Loader_Base.ReadFullJsonData(SubDir)
		#for _v in FileDetails.keys():
			#if(NewFileInfo.has(_v)): NewFileInfo[_v] = FileDetails[_v]
		var ConvText = JSON.parse_string(ItemFileContentSection.text)
		ConvText["Type"] = ExportType.get_item_text(ExportType.selected)
		Mod_Loader_Base.WriteFullJsonData(SubDir,ConvText)
		#Export scene to file set local stuff simaltaniously
		var CurrentExportScene = EditorInterface.get_edited_scene_root()
		
		#var TextureReCalb = Node.new()
		#TextureReCalb.name = "Texture Fixer"
		#TextureReCalb.set_script(load("res://ModLoader/Mis/Mod_TextureReassigner.gd"))
		#DupC.add_child(TextureReCalb) # Add texture recalabrate Node
		#TextureReCalb.owner = DupC
		#await get_tree().process_frame
		
		#Add extra nodes
		var ClearLater = Mod_Texture_Reassigner.new()
		CurrentExportScene.add_child(ClearLater)
		ClearLater.name = "Mod Fix"
		ClearLater.owner = CurrentExportScene
		#Save for mod fixes
		EditorInterface.save_scene()
			
		call_deferred("QuickExportF",CurrentExportScene,SubDir.get_basename()+".tscn")
		
		call_deferred("QuickRemoveObjects", CurrentExportScene,[ClearLater])
		#Mod_Exporter_Tool.ExportSceneToModAsset(DupC,SubDir.get_basename()+".tscn")
		
		pass
		
func QuickRemoveObjects(_scene:Node, _nodes:Array) -> void:
	for _n in _nodes:
		_scene.remove_child(_n)
		_n.queue_free()
		EditorInterface.save_scene()
		
func QuickExportF(_Node:Node, _path:String) -> void:
	Mod_Exporter_Tool.ExportSceneToModAsset(_Node,_path)
	#Mod_Export_Scene_Object.new().Export(_Node,_path)
	var ModFolder = _path.get_base_dir().get_base_dir()
	var ModFolderReferences = ModFolder+"/_References.json"
	var RefsExist = Mod_Loader_Base.HasOrCreateFile(ModFolderReferences,Mod_Exporter_Tool.DefaultReferenceFile)
	var FCRef:Dictionary = Mod_Loader_Base.ReadFullJsonData(ModFolderReferences)
	var NewPerFileRef:Dictionary = Mod_Exporter_Tool.CalculateActivePathLines(_path)
	FCRef["Update-Lines"][_path.get_file().get_basename()] = NewPerFileRef
	print("Ball A ", FCRef, " | ", NewPerFileRef)
	Mod_Loader_Base.WriteFullJsonData(ModFolderReferences,FCRef)
	



func ItemTypeSelected(index: int) -> void:
	NewFileInfo = ExportTypeFiles[index].data
	ItemFileContentSection.text = JSON.stringify(NewFileInfo, "\t")
	pass # Replace with function body.
	
func SetTypeSelected(_s:Dictionary) -> void:
	NewFileInfo = _s
	ItemFileContentSection.text = JSON.stringify(NewFileInfo, "\t")

func SaveEditedModInfo() -> void:
	var ModDataAdress = ModDirectory + "/" + CurrentModName + "/" + CurrentModName +".json"
	var RawModP:Dictionary = JSON.parse_string(ModFileContentSection.text)
	if(RawModP != null):
		var FMT = Mod_Loader_Base.WriteFullJsonData(ModDataAdress,RawModP)

func SaveEditedItemInfo() -> void:
	var DataAdress = ModDirectory + "/" + CurrentModName + "/" + CurrentSubName + "/" + CurrentSubName +".json"
	var RawDataP:Dictionary = JSON.parse_string(ItemFileContentSection.text)
	if(RawDataP != null):
		var FMT = Mod_Loader_Base.WriteFullJsonData(DataAdress,RawDataP)
		
	pass # Replace with function body.

func CallPopUp(_Command = "fart") -> void:
	QueuedFunctionToQ = _Command
	$AreYouSure.position = get_window().position + (get_window().size/2) - ($AreYouSure.size/2)
	$AreYouSure.visible = true

func QuickPopUpClick(index: int) -> void:
	$AreYouSure.visible = false
	if(index == 1):
		call_deferred(QueuedFunctionToQ)
	else:
		return
	pass # Replace with function body.


func SubmittedNewModFolder(new_text: String) -> void:
	PrefDetails["mods-folder"] = new_text
	ModDirectory = PrefDetails["mods-folder"]
	Mod_Loader_Preferences.SaveFromToPreferences(PrefDetails)
	pass # Replace with function body.
