@tool
extends Node
class_name Mod_Exporter_Tool

static var NonExportItems:Dictionary = {MultiplayerAPI:true}

static var NonExportFolders:Array = ["res://components","res://characters/base_player","res://ModLoader"]

static var CurrentModReferencePool:Dictionary = {}

static func ExportSceneToModAsset(_scene:Node,_path="G:/mods/modtest") -> void:
	var OriginalResources = GetAllResourcesInNode(_scene)
	var ExportFolder = _path.get_base_dir()
	var ResourceMap:Dictionary = {}
	for res_path in OriginalResources:
		if(!InExcludedPath(res_path)): # Store copyed files into buffer resources, also add pathing in a Resource Dicy
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
	ResourceSaver.save(PackedSceneRef,_path,ResourceSaver.FLAG_NONE)
	Mod_Loader_Base.FixAtGunPoint(_path)
	
static func GetAllResourcesInNode(_N:Node) -> Array:
	var RefArray = []
	GetRecurseResource(_N,RefArray)
	return RefArray
	
static func GetRecurseResource(_N:Node,_R:Array) -> void:
	for _p in _N.get_property_list():
		if(_p.has("type") && _p.has("name")):
			var n = _p["name"]
			var value = _N.get(n)
			if typeof(value) == TYPE_OBJECT && value is Resource:
				var res:Resource = value as Resource
				if res.resource_path != "" && !_R.has(res.resource_path):
					_R.append(res.resource_path)
					
	for _C in _N.get_children():
		GetRecurseResource(_C,_R)
		
static func CopyResourcesWhereApp(_N:Node, Dirmap: Dictionary, _modpath:String) -> Node:
	var Cloned = _N.duplicate(DUPLICATE_USE_INSTANTIATION)
	CopyResourceIndiviual(Cloned,Dirmap,_modpath)
	return Cloned
	
static func CopyResourceIndiviual(_N:Node, Dirmap: Dictionary, _modpath:String) -> void:
	for _prop in _N.get_property_list():
		if _prop.has("name") && _prop.has("type"):
			var name = _prop["name"]
			var value = _N.get(name)
			if typeof(value) == TYPE_OBJECT && value is Resource:
				var res: Resource = value
				var old_path = res.resource_path
				if Dirmap.has(old_path):
					var TargetFilePath:String = _modpath.get_base_dir()+Dirmap[old_path].substr(1,Dirmap[old_path].length()-1)
					var new_res = load(TargetFilePath)  # assumes the resource is in the export root
					if(TargetFilePath.ends_with(".png")):
						_N.set_meta("HAS_IMAGE",true)
						var TestM = name
						var RelAdress = TargetFilePath.substr(_modpath.get_base_dir().get_base_dir().get_base_dir().length()+1)
						_N.set_meta(TestM, RelAdress)
					if new_res:
						# Would set resource path here but godot literally wouldnt include in export, so me :-(
						#new_res.resource_path = Dirmap[old_path]
						_N.set(name, new_res)
					else:
						if(TargetFilePath.ends_with(".png")):
							var TempTexture = Texture2D.new()
							TempTexture.resource_path = TargetFilePath
							_N.set(name, TempTexture)
	for _child in _N.get_children():
		if _child is Node:
			CopyResourceIndiviual(_child, Dirmap,_modpath)
	

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
