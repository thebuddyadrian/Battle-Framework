extends Node

var _character_info_dict: Dictionary[String, CharacterInfo]


func _init() -> void:
	for character in Lists.characters:
		_character_info_dict[character] = load("res://characters/%s/%s.tres" % [character, character])


func get_character_info(character_name: String):
	assert(_character_info_dict.has(character_name), "Cannot find CharacterInfo for %s" % character_name)
	return _character_info_dict[character_name]
