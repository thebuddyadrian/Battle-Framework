extends Node
class_name Mod_Exporter_Tool

static var NonExportItems:Dictionary = {MultiplayerAPI:true}

static func ExportFullSceneToModAsset(_scene:Node,_path="G:/mods/modtest") -> void:
	var Assets:Dictionary = {"OBJ":{},"RES":{}}
	#Save base scene to file
	var PackedSceneRef = PackedScene.new()
	PackedSceneRef.pack(_scene)
	#New Scene Instance
	var SceneCopy = PackedSceneRef.instantiate()
	
	
	
	print("Assets : ", GetSceneResources(SceneCopy))
	
	PackedSceneRef.pack(SceneCopy)
	var sc_err = ResourceSaver.save(PackedSceneRef,_path)
	
	if sc_err != OK: # Quick Scene Error check
		push_error("Failed to save scene: "+_path)
	
static func GetSceneResources(_scene:Node) -> Array:
	var _resources = []
	GetNodeRResource(_scene,_resources)
	return _resources
	
static func GetNodeRResource(_node:Node, _resources:Array) -> void:
	for _prop in _node.get_property_list():
		if _prop.has("type"):
			var _p_value = _node.get(_prop.name)
			if(typeof(_p_value) == TYPE_OBJECT && _p_value is Resource && !NonExportItems.has(_prop.type)):
				var Res:Resource = _p_value
				if Res.resource_path != "" && !_resources.has(Res.resource_path):
					_resources.push_back(Res.resource_path)
					
	for _child in _node.get_children():
		if _child is Node:
			GetNodeRResource(_child,_resources)
	

static func ExportSceneWithFiles(_path="G:/mods/modtest",_submod="TestChar",_modProfile:Dictionary = {}) -> void:
	
	pass
