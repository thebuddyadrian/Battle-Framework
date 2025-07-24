extends Node
class_name Mod_Exporter_Tool

static func ExportFullSceneToModAsset(_scene:Node,_path="G:/mods/modtest") -> void:
	var Assets:Dictionary = {"OBJ":{},"RES":{}}
	for _item in _scene.get_property_list():
			if(_item.type == TYPE_OBJECT):
				var _obj = _scene.get(_item.name)
				if _obj is Resource:
					var _obj_id:String = _path + "/" + _item.name
					if _obj.resource_path.contains("::"):
						var resourceID: String = _obj.resource_path
						Assets.RES[resourceID] = _obj_id
						Assets.OBJ[_obj] = _obj
					pass
	var PackedSceneRef = PackedScene.new()
	PackedSceneRef.pack(_scene)
	ResourceSaver.save(PackedSceneRef,_path)

static func ExportSceneWithFiles(_path="G:/mods/modtest",_submod="TestChar",_modProfile:Dictionary = {}) -> void:
	
	pass
