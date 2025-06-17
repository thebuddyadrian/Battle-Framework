extends Node

var CLIENTSIDE_PLAYER = null

var CONTROLS_FILE_PATH = "user://controls.tres"
var saved_input_map := {}
var action_list = ["left", "right", "up", "down", "jump", "attack", "upper", "skill", "guard", "dash"]


func save_controls():
	for action in action_list:
		for i in range(1, 5): #1 - 4
			var player_action = action + str(i)
			saved_input_map[player_action] = InputMap.action_get_events(player_action)
	
	var controls_file = FileAccess.open(CONTROLS_FILE_PATH, FileAccess.WRITE)
	controls_file.store_var(saved_input_map, true)


func load_controls():
	if saved_input_map.is_empty():
		if FileAccess.file_exists(CONTROLS_FILE_PATH):
			var controls_file = FileAccess.open(CONTROLS_FILE_PATH, FileAccess.READ)
			saved_input_map = controls_file.get_var(true)
	
	for action in saved_input_map:
		if !InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var event_list = saved_input_map[action]
		for event in event_list:
			InputMap.action_add_event(action, event)