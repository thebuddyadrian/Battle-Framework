@tool
extends ResourceFormatSaver

func _get_recognized_extensions(resource):
	return PackedStringArray(["png","jpeg"])


func _recognize(resource):
	return resource is ImageTexture


func _save(resource, path, flats):
	if not resource:
		return ERR_INVALID_PARAMETER

	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		var err = FileAccess.get_open_error()
		if err != OK:
			push_error("Cannot save GDScript file %s." % path)
			return err
 
		if (file.get_error() != OK and file.get_error() != ERR_FILE_EOF):
			return ERR_CANT_CREATE
	
	# In the linked GDScript sample, it also does an internal ScriptServer check that you wouldn't need,
	# but for completion's sake: the getter/setter just wraps a bool, and the setter is called with
	# an EditorSettings value, so it'd be something like this in GDScript
	var settings = EditorInterface.get_editor_settings()
	if settings.get_setting("text_editor/behavior/files/auto_reload_and_parse_scripts_on_save"):
		pass

	return OK
