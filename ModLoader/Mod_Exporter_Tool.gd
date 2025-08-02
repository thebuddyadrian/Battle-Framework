@tool
extends Node
class_name Mod_Exporter_Tool

static var NonExportItems:Dictionary = {MultiplayerAPI:true}

static var NonExportFolders:Array = ["res://components","res://characters/base_player","res://ModLoader","res://characters/mini_bar.gd"]
static var DefaultReferenceFile:String = preload("res://ModLoader/Defaults/DefaultResourcePool.json").get_parsed_text()

static var CustomResourceOrder:Array = [".tscn",".gd",".tres",".res",".png",".jepg"]
static var CurrentModReferencePool:Dictionary = {}

static var ScriptSwapQueue:Dictionary = {} #Avoid having to store and reassign all values for node after script change, change in .tscn file

static func ExportSceneToModAsset(_scene:Node,_path="G:/mods/modtest") -> void:
	var OriginalResources = GetAllResourcesInNode(_scene)
	OriginalResources.sort_custom(SortResFile)
	var ExportFolder = _path.get_base_dir()
	var ResourceMap:Dictionary = {}
	for res_path in OriginalResources:
		if(!InExcludedPath(res_path)): # Store copyed files into buffer resources, also add pathing in a Resource Dic
			var filename = res_path.get_file()
			var out_file_path = filename
			var in_file := FileAccess.open(res_path, FileAccess.READ)
			if in_file:
				var data = in_file.get_buffer(in_file.get_length())
				in_file.close()

				var out_file := FileAccess.open(ExportFolder+"/"+out_file_path, FileAccess.WRITE)
				out_file.store_buffer(data)
				out_file.close()
				
				ResourceMap[res_path] = "./"+out_file_path  # Just filename , relative 
	
	var NewRef = CopyResourcesWhereApp(_scene, ResourceMap,_path)
	NewRef.name = _path.get_file().get_basename()
	for _R in ResourceMap.keys():
		print("Resources ", _R , " | ", ResourceMap[_R])
	
	var PackedSceneRef = PackedScene.new()
	PackedSceneRef.pack(NewRef.duplicate(DUPLICATE_SIGNALS | DUPLICATE_SCRIPTS | DUPLICATE_GROUPS | DUPLICATE_USE_INSTANTIATION))
	NewRef.queue_free()
	ResourceSaver.save(PackedSceneRef,_path,ResourceSaver.FLAG_NONE)
	Mod_Loader_Base.FixAtGunPoint(_path,ScriptSwapQueue)
	
static func SortResFile(a,b) -> bool:
	if(CustomResourceOrder.find(a.get_extension()) < CustomResourceOrder.find(b.get_extension())):
		return true
	else: return false
	
static func GetAllResourcesInNode(_N:Node) -> Array:
	var RefArray = []
	GetRecurseResource(_N,RefArray,0,0)
	return RefArray
	
static func GetRecurseResource(_N:Node,_R:Array,_Dep:int,_Index:int) -> void:
	for _p in _N.get_property_list():
		if(_p.has("type") && _p.has("name")):
			var n = _p["name"]
			var value = _N.get(n)
			
			#Array
			if (value is Array):
				for _i in range(value.size()):
					SingleResourceDetect(value[_i],_R)
			#Dictionary
			elif (value is Dictionary):
				for _D in range(value.size()):
					SingleResourceDetect(value.keys().get(_D),_R)
					SingleResourceDetect(value.values().get(_D),_R)
			else: # Normal variables
				SingleResourceDetect(value,_R)
					
	for _C in range(_N.get_children().size()):
		GetRecurseResource(_N.get_child(_C),_R,_Dep+1,_Index+_C)
		
static func SingleResourceDetect(_value, _R:Array) -> void:
	if (typeof(_value) == TYPE_OBJECT && _value is Resource):
		var res:Resource = _value as Resource
		if res.resource_path != "" && !_R.has(res.resource_path):
			_R.append(res.resource_path)
		
static func CopyResourcesWhereApp(_N:Node, Dirmap: Dictionary, _modpath:String) -> Node:
	ScriptSwapQueue.clear()
	var Cloned = _N.duplicate(DUPLICATE_SIGNALS | DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_USE_INSTANTIATION)
	_N.get_parent().add_child(Cloned)
	Cloned.owner = _N.get_parent()
	CopyResourceIndiviual(Cloned,_N,Dirmap,_modpath,0,0)
	return Cloned
	
static func CopyResourceIndiviual(_N:Node,_Original:Node, Dirmap: Dictionary, _modpath:String, _Dep:int, _Index:int) -> void:
	#print("N F ", _N.name, " | ",_Dep)
	#print("Lord Forquad ", LastResourceFol[[_Original.name,_Dep,_Index]])
	for _prop in _N.get_property_list():
		if _prop.has("name") && _prop.has("type"):
			var name = _prop["name"]
			var value = _N.get(name)
			#Array
			if (value is Array):
				for _i in range(value.size()):
					CopyResourceIndiviualIsntF(value[_i],_N,name,[value,_i],Dirmap,_modpath)
			#Dictionary
			elif (value is Dictionary):
				for _k in value.keys():
					#CopyResourceIndiviualIsntF(value.keys()[_D],_N,name,[TempDict,0_D],Dirmap,_modpath)
					CopyResourceIndiviualIsntF(value[_k],_N,name,[value,1,_k],Dirmap,_modpath)
			else: # Normal variables
				CopyResourceIndiviualIsntF(value,_N,name,[],Dirmap,_modpath)
			
	for _CI in range(_N.get_children().size()):
		if _N.get_child(_CI) is Node:
			var ChildRef = _N.get_child(_CI)
			CopyResourceIndiviual(ChildRef,_Original.get_node(ChildRef.get_path()), Dirmap,_modpath,_Dep+1,_Index+_CI)
			
static func CopyResourceIndiviualIsntF(value,_N:Node,_name:String,_key,_Dirmap:Dictionary,_modpath:String) -> void:
	if typeof(value) == TYPE_OBJECT && value is Resource:
		var res: Resource = value
		var old_path = res.resource_path
		if _Dirmap.has(old_path):
			#Create target path remove "." from "./" here aswell
			var TargetFilePath:String = _modpath.get_base_dir()+_Dirmap[old_path].substr(1,_Dirmap[old_path].length()-1)
			
			var new_res = null  # assumes the resource is in the export root
			if !(res is GDScript): new_res = load(TargetFilePath)
			else: ScriptSwapQueue[old_path] = TargetFilePath
			
			if(TargetFilePath.ends_with(".png")):
				_N.set_meta("HAS_IMAGE",true)
				var TestM = _name
				var RelAdress = TargetFilePath.substr(_modpath.get_base_dir().get_base_dir().get_base_dir().length()+1)
				_N.set_meta(TestM, RelAdress)
			#if(new_res is GDScript):
				#_N.get(_name).resource_path = TargetFilePath
			if new_res && new_res != null:
				# Would set resource path here but godot literally wouldnt include in export, so me :-(
				#new_res.resource_path = Dirmap[old_path]
				if(_key != []):
					if(_key[0] is Array):
						_key[0][_key[1]] = new_res
						_N.set(_name, _key[0])
						#TempHold[]
					elif(_key[0] is Dictionary):
						if(_key[1] == 0):
							_key[0].get_or_add(new_res,"")
						if(_key[1] == 1):
							_key[0][_key[2]] = new_res
						_N.set(_name, _key[0])
				else:
					_N.set(_name, new_res)
			else:
				if(TargetFilePath.ends_with(".png")):
					var TempTexture = Texture2D.new()
					TempTexture.resource_path = TargetFilePath
					_N.set(_name, TempTexture)
			
static func SortExportResource(_path:String) -> void:
	var ModFolder = _path.get_base_dir().get_base_dir()
	var ModFolderReferences = ModFolder+"/_References.json"
	var RefsExist = Mod_Loader_Base.HasOrCreateFile(ModFolderReferences, DefaultReferenceFile)
	var FCRef:Dictionary = Mod_Loader_Base.ReadFullJsonData(ModFolderReferences)
	var NewPerFileRef:Dictionary = CalculateActivePathLines(_path)
	FCRef["Update-Lines"][_path.get_file().get_basename()] = NewPerFileRef
	print("Ball A ", FCRef, " | ", NewPerFileRef)
	Mod_Loader_Base.WriteFullJsonData(ModFolderReferences,FCRef)
	
#Used to find lines in a newly created scene that have relative path references
static func CalculateActivePathLines(_path:String) -> Dictionary:
	var OutDir:Dictionary = {"start_line":0,"end_line":0}
	var tscn_file = FileAccess.open(_path, FileAccess.READ)
	var tscn_file_Raw = tscn_file.get_as_text()
	var tscn_file_lines = tscn_file_Raw.split('\n')
	tscn_file.close()
	var NewFileOut = ""
	var EngagedFiles:bool = false
	for _i in range(tscn_file_lines.size()):
		if(tscn_file_lines[_i].contains("path=")):
			var PointofP = tscn_file_lines[_i].find("path=")
			if(PointofP >= 0):
				if(!EngagedFiles):
					OutDir["start_line"] = _i
				EngagedFiles = true
		else:
			if(EngagedFiles):
				OutDir["end_line"] = _i
				EngagedFiles = false
				return OutDir
	return OutDir
	

static func ExportFullSceneToModAsset(_scene:Node,_path="G:/mods/modtest") -> void:
	var Assets:Dictionary = {"OBJ":{},"RES":{}}
	CurrentModReferencePool = {}
	#Save base scene to file
	
	var PackedSceneRef = PackedScene.new()
	PackedSceneRef.pack(_scene.duplicate(DUPLICATE_SIGNALS | DUPLICATE_SCRIPTS | DUPLICATE_GROUPS | DUPLICATE_USE_INSTANTIATION))
	#New Scene Instance
	var SceneCopy = PackedSceneRef.instantiate()
	
	var ModFolder = _path.get_base_dir().get_base_dir()
	CurrentModReferencePool = Mod_Loader_Base.ReadFullJsonData(ModFolder+"/_References.json")
	#print("Assets : ", JSON.stringify(GetSceneResources(SceneCopy,_path),"\t"))
	
	
	PackedSceneRef.pack(SceneCopy)
	#Useful flags  | ResourceSaver.FLAG_BUNDLE_RESOURCES
	var sc_err = ResourceSaver.save(PackedSceneRef,_path,ResourceSaver.FLAG_RELATIVE_PATHS | ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS | ResourceSaver.FLAG_CHANGE_PATH)
	SceneCopy.queue_free()
	if sc_err != OK: # Quick Scene Error check
		push_error("Failed to save scene: "+ _path)
	
static func GetSceneResources(_scene:Node,_path:String) -> Array:
	var _resources = []
	GetNodeRResource(_scene,_resources,_path)
	return _resources
	
static func GetNodeRResource(_node:Node, _resources:Array, _path:String) -> void:
	for _prop in _node.get_property_list():
		if _prop.has("type"):
			var _p_value = _node.get(_prop.name)
			if(typeof(_p_value) == TYPE_OBJECT && _p_value is Resource && !NonExportItems.has(_prop.type)):
				var Res:Resource = _p_value
				var ExcludedPath:bool = false
				for _pp in NonExportFolders:
					if(Res.resource_path.containsn(_pp)) : ExcludedPath = true
				print("P _ ",Res.resource_path, " IsU ", ExcludedPath)
				#if(CurrentModReferencePool.has(Res.resource_path)):
					#Res.resource_path = CurrentModReferencePool[Res.resource_path]
				#else:
				if Res.resource_path != "" && !_resources.has(Res.resource_path) && !ExcludedPath:
					var New_Res = Res.duplicate(true)
					var New_Res_Path = _path.get_base_dir() + "/" + Res.resource_path.get_file()
					print("Arr ", Res.resource_path.get_file())
					ResourceSaver.save(New_Res,(_path.get_base_dir() + "/" + Res.resource_path.get_file()))
					Res.resource_path = "./" + Res.resource_path.get_file()
					_resources.push_back(Res.resource_path)
			
			#Export texture
			if(_p_value is Texture2D && !NonExportItems.has(_prop.type)):
				var ResTexture:Texture2D = _p_value
				print("Texture Out : " + _p_value.property_path)
				pass
				
	for _child in _node.get_children():
		if _child is Node:
			GetNodeRResource(_child,_resources,_path)

static func ExportSceneWithFiles(_path="G:/mods/modtest",_submod="TestChar",_modProfile:Dictionary = {}) -> void:
	
	pass
			
static func InExcludedPath(_path ="") -> bool:
	for _pp in NonExportFolders:
		if(_path.begins_with(_pp)) : 
			#print("Contains ", _pp, " | ", NonExportFolders) 
			return true
	#print("Does not Contains") 
	return false
