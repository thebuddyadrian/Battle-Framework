extends Node

var CLIENTSIDE_PLAYER = null

var CONTROLS_FILE_PATH = "user://controls.tres"
var saved_input_map := {}
var action_list = ["left", "right", "up", "down", "attack", "skill", "guard", "dash"]


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


# For now, it just takes the player 1 gamepad controls and add it to the other players
# Then sets the device index to 0, 1, 2, 3, etc.
# In the future this should be removed and players should set their gamepad controls in the settings or something
func generate_gamepad_controls():
	for action in InputMap.get_actions():
		if action.ends_with("1"):
			var gamepad_events: Array[InputEvent]
			for event in InputMap.action_get_events(action):
				if event is InputEventJoypadButton or event is InputEventJoypadMotion:
					gamepad_events.append(event)
			
			for event in gamepad_events:
				event.device = 0
				for i in range(2, 5):
					var new_event: InputEvent = event.duplicate(true)
					new_event.device = i - 1
					var new_action = action.trim_suffix("1") + str(i)
					if !InputMap.has_action(new_action):
						InputMap.add_action(new_action)
					InputMap.action_add_event(new_action, new_event)
