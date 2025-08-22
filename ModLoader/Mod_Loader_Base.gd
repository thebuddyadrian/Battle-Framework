@tool
extends Node
class_name Mod_Loader_Base

static var TempJSONCache:Dictionary = {}

#Uses Absoulte Path
static func HasOrCreateFolder(_folder="user://mods") -> bool:
	if(!DirAccess.dir_exists_absolute(_folder)):
		DirAccess.make_dir_absolute(_folder)
		return false
	return true
	
#Uses Absoulte Path
static func HasOrCreateFile(_file="user://mods",_defaultdata="") -> bool:
	if(!FileAccess.file_exists(_file)):
		var file = FileAccess.open(_file, FileAccess.WRITE)
		file.store_string(_defaultdata)
		file.close()
		return false
	return true
	
static func GetAllFoldersFromDir(_path="G:/Something/Something") -> Array:
	var FFD:Array = []
	FFD.assign(DirAccess.get_directories_at(_path))
	return FFD
	
#Reads All json data to Dict
static func ReadFullJsonData(_file="user://temp.json",_override:bool = false) -> Dictionary:
	if(TempJSONCache.has(_file) && !_override): return TempJSONCache[_file]
	if(FileAccess.file_exists(_file)):
		var TempFile = FileAccess.open(_file,FileAccess.READ)
		var JOut = JSON.parse_string(TempFile.get_as_text())
		TempFile.close()
		TempJSONCache.get_or_add(_file,JOut)
		return JOut
	return {}
	
#Saves Data to Json file
static func WriteFullJsonData(_file="user://temp.json", _dict:Dictionary = {}) -> bool:
	if(FileAccess.file_exists(_file)):
		var TempFile = FileAccess.open(_file,FileAccess.WRITE)
		TempFile.store_string(JSON.stringify(_dict))
		TempFile.close()
		TempJSONCache[_file] = _dict
		return true
	return false
	
static func GetAllModFiles(_path="", _include_emptys:bool = false) -> Dictionary:
	var M_Dict = {}
	var ModFolders = GetAllFoldersFromDir(_path)
	for _mod:String in ModFolders:
		var SubModFolders = GetAllFoldersFromDir(_path+"/"+_mod)
		print("S ",_mod)
		if(_include_emptys && FileAccess.file_exists(_path+"/"+_mod+"/"+_mod+".json")): M_Dict.get_or_add(_mod,[])
		for _submod in SubModFolders:
			var AbRefPath = _path+"/"+_mod+"/"+_submod
			#Check if Mod Has JSON
			var ModJsonData = ReadFullJsonData(AbRefPath + "/"+_submod+".json")
			var ModdedAssetDir = AbRefPath + "/"+_submod+".tscn"
			if(ModJsonData.has("Type")):
				var TM = M_Dict.get_or_add(_mod,[AbRefPath])
				if(!TM.has(AbRefPath)): TM.push_back(AbRefPath)
	return M_Dict

static func CalculateActiveMods(_M_Dict:Dictionary, _MFolder_Path:String, _DisabledMods:Array, _DisabledSubs:Array) -> Dictionary:
	var A_M_Dict = {}
	for _mod in _M_Dict.keys():
		if(!_DisabledMods.has(_mod)):
			for _submod in _M_Dict[_mod]:
				var RelPath = _submod.substr(_MFolder_Path.length()+1,_submod.length())
				if(!_DisabledSubs.has(RelPath) && IsModSafe(RelPath)):
					var TM = A_M_Dict.get_or_add(_mod,[_submod])
					if(!TM.has(_submod)): TM.push_back(_submod)
	return A_M_Dict
	
static func IsModSafe(_subpath="") -> bool:
	var FullPath = ModLoaderMaster.ModFolderDirectory + "/"+_subpath
	#var LoadedAsset:PackedScene = load(FullPath+"/"+FullPath.get_file()+".tscn")
	#print("Mod Checking ", ScriptRefA)
	return true
	
static func CalculateModTypes(_M_Dict:Dictionary, _ModFolder="") -> Dictionary:
	var R_Dict = {}
	for _mod in _M_Dict:
		for _submod:String in _M_Dict[_mod]:
			var ModJsonData = ReadFullJsonData(_submod+"/"+_submod.get_file()+".json")
			if(ModJsonData.has("Type")):
				var TM = R_Dict.get_or_add(ModJsonData["Type"],[_submod])
				if(!TM.has(_submod)): TM.push_back(_submod)
	return R_Dict
	
static func GetQuickJson(_path ="") -> String:
	return _path+"/"+_path.get_file()+".json"

#Uses Relative Path

static func FixSelectedMods(_modPaths:Array) -> void:
	for _subs in _modPaths:
		for _path:String in _subs:
			var ModdedAssetDir = _path.get_basename()+"/"+_path.get_file().get_basename() + ".tscn"
			if(FileAccess.file_exists(ModdedAssetDir)):
				Mod_Loader_Base.FixAtNerfPoint(ModdedAssetDir)

#Might move later useful for texture refresh
static func SetDefaultImageTemp(_path:String, _vars=[]) -> bool:
	HasOrCreateFile(_path,"")
	var RefFile = FileAccess.open(_path, FileAccess.WRITE)
	var File = GetDefaultImageTemplate("res://ModLoader/Defaults/DefaultImageTemplate.txt",_vars)
	RefFile.store_string(File)
	return false
static func GetDefaultImageTemplate(_path="",_vars=[]) -> String:
	var text = FileAccess.open(_path, FileAccess.READ)
	var ConvertWithV = text.get_as_text() % _vars
	text.close()
	return ConvertWithV

static func FixAtNerfPoint(_modpath:String) -> void: #Drop in replacement for force at Gun point that uses a _reference file
	var RefPath = GetReferencesFromModPath(_modpath)
	print("Test Ref ",RefPath)
	var LoadReference = ReadFullJsonData(RefPath,true)
	
	var tscn_file = FileAccess.open(_modpath, FileAccess.READ_WRITE)
	var tscn_file_Raw = tscn_file.get_as_text()
	var tscn_file_lines:Array = tscn_file_Raw.split('\n')
	var OutNewTscnFile:String = ""
	if(!LoadReference["Update-Lines"].has(_modpath.get_file().get_basename())) : return
	var PathPoints:Array = [
		LoadReference["Update-Lines"][_modpath.get_file().get_basename()]["start_line"],
		LoadReference["Update-Lines"][_modpath.get_file().get_basename()]["end_line"]
	]
	for _l in range(tscn_file_lines.size()):
		if(_l >= PathPoints[0] || _l < PathPoints[1]):
			var PointofP = tscn_file_lines[_l].find("path=")
			if(PointofP >= 0):
				var pointE = tscn_file_lines[_l].findn("\"",PointofP+6)
				var OriginalFileDir = tscn_file_lines[_l].substr(PointofP+6,(pointE)-(PointofP+6))
				if(!OriginalFileDir.begins_with("res://")):
					OriginalFileDir = _modpath.get_base_dir()+"/"+OriginalFileDir.get_file()
					#Generate texture ref
					if(OriginalFileDir.contains(".png")):
						var NewUID = str(ResourceUID.create_id())
						SetDefaultImageTemp(OriginalFileDir+".import",[NewUID,OriginalFileDir])
						ResourceLoader.load(OriginalFileDir,"",ResourceLoader.CACHE_MODE_REPLACE)
						#print("IMAGE ",DefaultLoadedTextureImport)
					
				var NewL = tscn_file_lines[_l].substr(0,PointofP+6)+ OriginalFileDir + tscn_file_lines[_l].substr(pointE,tscn_file_lines[_l].length()-pointE)
				tscn_file_lines[_l] = NewL
		OutNewTscnFile += tscn_file_lines[_l] + '\n'
	tscn_file.store_string(OutNewTscnFile)
	tscn_file.close()
	pass

#Quick File fixer
static func FixAtGunPoint(_modpath:String, _QuickChanges:Dictionary = {}) -> void: #Force File at gun point to change directory for resource to local or watch its children cry in fear, (yesh.. thats dark)
	var tscn_file = FileAccess.open(_modpath, FileAccess.READ_WRITE)
	var tscn_file_Raw = tscn_file.get_as_text()
	var tscn_file_lines = tscn_file_Raw.split('\n')
	var NewFileOut = ""
	var EngagedFiles:bool = false
	var _lCount:int = 0
	for _line:String in tscn_file_lines:
		if(_line.contains("path=")):
			var PointofP = _line.find("path=")
			if(PointofP >= 0):
				EngagedFiles = true
				var pointE = _line.findn("\"",PointofP+6)
				var OriginalFileDir = _line.substr(PointofP+6,(pointE)-(PointofP+6))
				if(!OriginalFileDir.begins_with("res://")):
					OriginalFileDir = _modpath.get_base_dir()+"/"+OriginalFileDir.get_file()
					#Generate texture ref
					if(OriginalFileDir.contains(".png")):
						var NewUID = str(ResourceUID.create_id())
						SetDefaultImageTemp(OriginalFileDir+".import",[NewUID,OriginalFileDir])
						ResourceLoader.load(OriginalFileDir,"",ResourceLoader.CACHE_MODE_REPLACE)
						#print("IMAGE ",DefaultLoadedTextureImport)
					
				var NewL = _line.substr(0,PointofP+6)+ OriginalFileDir + _line.substr(pointE,_line.length()-pointE)
				_line = NewL
		else:
			if(EngagedFiles):
				pass # Were break would happen if file could be override for just new lines
		for _LT in _QuickChanges.keys():
			if(_line.contains(_LT)):
				_line = _line.replace(_LT,_QuickChanges[_LT])
		NewFileOut += _line + "\n"
	tscn_file.store_string(NewFileOut)
	tscn_file.close()

static func GetReferencesFromModPath(_path:String) -> String:
	return _path.get_base_dir().get_base_dir()+"/_References.json"
	
static func GetModIcons(_Mods:Dictionary) -> Dictionary:
	var OutIcons:Dictionary = {}
	for _M in _Mods.keys():
		OutIcons[_M] = {}
		for _S:String in _Mods[_M]:
			var DataC:Dictionary = ReadFullJsonData(_S.get_basename()+"/"+_S.get_file()+".json")
			var ImageDir:String = _S+"/"+DataC["Preview-Image"]
			var HasPreview:bool = FileAccess.file_exists(ImageDir)
			if(HasPreview):
				var I:Image = Image.load_from_file(ImageDir)
				var IT:ImageTexture = ImageTexture.create_from_image(I)
				OutIcons[_M][_S] = (IT)
			else:
				OutIcons[_M][_S] = null #load("res://ModLoader/assets/QuestionMark.png")
	return OutIcons
