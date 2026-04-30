extends Node
## Autoload class that manages custom controls for each player.

const MAX_PLAYERS: int = 4
## Defines which device ID will be read as the keyboard. Set to a high number to not conflict
## with gamepad device IDs.
const KEYBOARD_DEVICE_INDEX: int = 999
## File path where controls will be stored.
const CONTROLS_FILE_PATH: String = "user://controls.dat"
## List of actions used in gameplay.
const ACTION_LIST: Array = ["left", "right", "up", "down", "jump", "attack", "upper", 
		"skill", "guard", "dash", "pause"]

## Stores the inputs for all players as a Dictionary.
## Maps action name [String] -> event [InputEvent]
var saved_input_map: Dictionary = {}
## Stores which device each player is using.
var player_device_indicies: Dictionary = {}



## Saves controls settings to disk.
func save_controls():
	for action in ACTION_LIST:
		for i in range(MAX_PLAYERS):
			var player_action = action + str(i + 1)
			saved_input_map[player_action] = InputMap.action_get_events(player_action)
	
	var controls_file = FileAccess.open(CONTROLS_FILE_PATH, FileAccess.WRITE)
	controls_file.store_var(saved_input_map, true)
	controls_file.store_var(player_device_indicies, true)


# Loads controls settings from disk if they weren't loaded already
func load_controls():
	if saved_input_map.is_empty():
		if FileAccess.file_exists(CONTROLS_FILE_PATH):
			var controls_file = FileAccess.open(CONTROLS_FILE_PATH, FileAccess.READ)
			saved_input_map = controls_file.get_var(true)
			player_device_indicies = controls_file.get_var(true)
	
	for action in saved_input_map:
		if !InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var event_list = saved_input_map[action]
		for event in event_list:
			InputMap.action_add_event(action, event)
