extends Node #If you find in your scene do not remove it fixes moded assets textures

func _ready() -> void:
	RecursiveTs(get_parent())
	
	pass
	
func RecursiveTs(_N:Node) -> void:
	for _prop in _N.get_property_list():
		if(_prop.has("name") && _prop.has("type")):
			var name = _prop["name"]
			var value = _N.get(name)
			if(value is Resource):
				#var I_T = Image.load_from_file(value.resource_path)
				#var Convert = ImageTexture.create_from_image(I_T)
				#_N.set(name,Convert)
				pass
			if(_N.has_meta(name)): # Texture through meta
				if(_N.get_meta(name).ends_with(".png")):
					var I_T = Image.load_from_file(ModLoaderMaster.ModFolderDirectory + "/"+ _N.get_meta(name,""))
					var Convert = ImageTexture.create_from_image(I_T)
					print("Test ", )
					_N.set(name,Convert)
				
	for _child in _N.get_children(false):
		RecursiveTs(_child)
