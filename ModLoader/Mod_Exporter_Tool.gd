@tool
extends Node
class_name Mod_Exporter_Tool

static var NonExportItems:Dictionary = {MultiplayerAPI:true}

static var NonExportFolders:Array = ["res://components","res://characters/base_player"]

static var CurrentModReferencePool:Dictionary = {}

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
	print("Assets : ", JSON.stringify(GetSceneResources(SceneCopy,_path),"\t"))
	
	
	PackedSceneRef.pack(SceneCopy)
	# Useful flags  | ResourceSaver.FLAG_BUNDLE_RESOURCES
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
				print("Texture Out : " + ResTexture.property_path)
				pass
				
	for _child in _node.get_children():
		if _child is Node:
			GetNodeRResource(_child,_resources,_path)

static func ExportSceneWithFiles(_path="G:/mods/modtest",_submod="TestChar",_modProfile:Dictionary = {}) -> void:
	
	pass
