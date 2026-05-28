extends Node
## Autoload class that manages custom controls for each player.
# TO-DO Define action lists using a resource so it can be changed more easily per project.


enum INPUT_TYPE {NONE = 0, KEYBOARD = 1, GAMEPAD = 2} # NONE is used if selection hasn't been made

const MAX_LOCAL_PLAYERS: int = 4
## List of actions used in gameplay.
const GAMEPLAY_ACTIONS: Array = ["left", "right", "up", "down", "jump", "attack", "upper", 
		"skill", "guard", "dash", "pause"]
## List of actions used in the UI.
const UI_ACTIONS: Array = ["ui_left", "ui_right", "ui_up", "ui_down", "ui_accept", "ui_cancel",
		"ui_left_corner", "ui_right_corner"]
const USER_BUTTON_LAYOUTS_DIR: String = "user://button_layouts/"
const DEFAULT_GAMEPAD_BUTTON_LAYOUT_PATH: String = "res://data/default_gamepad_button_layout.dat"
const DEFAULT_KEYBOARD_BUTTON_LAYOUT_PATH: String = "res://data/default_keyboard_button_layout.dat"
const CONTROLS_SETTINGS_PATH: String = "user://controls_settings.dat"

## Stores the device ID of the gamepad each local player is using
var player_device_ids := {1:0, 2:1}
var player_input_types: Dictionary[int, INPUT_TYPE] = {1: INPUT_TYPE.KEYBOARD, 2:INPUT_TYPE.KEYBOARD} # Stores the input type each player uses (Keyboard/Gamepad)
## Stores other player's input types to ensure synchronization for code that checks input types
var online_input_types: Dictionary[int, INPUT_TYPE] = {1: INPUT_TYPE.KEYBOARD, 2:INPUT_TYPE.KEYBOARD} # Stores the input type each player uses (Keyboa

# Stores two button layouts for each player as a dictionary, for Keyboard and Gamepad
# Will be applied to InputMap at the start of the match (See MatchScene.gd)
# {
# 	player_no <int>: {
# 		INPUT_TYPE.KEYBOARD : button_layout <Dictionary[String, Array[InputEvent]]>, # Dictionary mapping action names to an array of InputEvents
# 		INPUT_TYPE.GAMEPAD : button_layout <Dictionary[String, Array[InputEvent]]>,
# 	}
# }
var player_button_layouts: Dictionary = {}


func save_controls_settings():
	var settings_file := FileAccess.open(CONTROLS_SETTINGS_PATH, FileAccess.WRITE)
	if !settings_file:
		print("Error saving controls settings!")
	else:
		settings_file.store_var(player_device_ids, false)
		settings_file.store_var(player_input_types, false)
		settings_file.close()


func load_controls_settings():
	var settings_file := FileAccess.open(CONTROLS_SETTINGS_PATH, FileAccess.READ)
	if !settings_file:
		print("Error loading controls settings!")
	else:
		player_device_ids = settings_file.get_var()
		player_input_types = settings_file.get_var()
		settings_file.close()


# Returns the proper string file path for a stored button layout file for a
# specific player and button layout
func get_button_layout_file_path(player_no: int, input_type: INPUT_TYPE) -> String:
	var filename: String = "p%s_%s_button_layout.dat" % [
			player_no, input_type_to_string(input_type).to_snake_case()]
	return USER_BUTTON_LAYOUTS_DIR.path_join(filename)


# Saves a player's button layout to disk as a file.
func save_button_layout(player_no: int, input_type: INPUT_TYPE):
	var button_layout: Dictionary[String, Array]  = get_button_layout(player_no, input_type)
	# If button layout doesn't exist, no need to save
	if button_layout.is_empty():
		return
	# Make sure button layout directory exists
	if !DirAccess.dir_exists_absolute(USER_BUTTON_LAYOUTS_DIR):
		DirAccess.make_dir_absolute(USER_BUTTON_LAYOUTS_DIR)
	var layout_path: String = get_button_layout_file_path(player_no, input_type)
	var layout_file := FileAccess.open(layout_path, FileAccess.WRITE)
	if !layout_file:
		print("Error saving player button layout!")
		return
	layout_file.store_var(button_layout, true)
	layout_file.close()



# Load a player's button layout from disk
func load_button_layout(player_no: int, input_type: INPUT_TYPE):
	var layout_path: String = get_button_layout_file_path(player_no, input_type)
	var layout_file := FileAccess.open(layout_path, FileAccess.READ)
	if !layout_file:
		# Fall back to default layout
		print("Unable to load button layout, falling back to default (P%s, Input Type: %s)" % [player_no, input_type])
		load_default_button_layout(player_no, input_type)
		return
	var button_layout: Dictionary[String, Array] = layout_file.get_var(true)
	set_button_layout(player_no, input_type, button_layout)


# Save button layouts for all players and input types
func save_all_button_layouts():
	for i in range(MAX_LOCAL_PLAYERS):
		save_button_layout(i + 1, INPUT_TYPE.KEYBOARD)
		save_button_layout(i + 1, INPUT_TYPE.GAMEPAD)


# Load button layouts for all players and input types
func load_all_button_layouts():
	for i in range(MAX_LOCAL_PLAYERS):
		load_button_layout(i + 1, INPUT_TYPE.KEYBOARD)
		load_button_layout(i + 1, INPUT_TYPE.GAMEPAD)



# Saves a player's button layout as the default for an input type. Meant to be used during
# development.
func save_button_layout_as_default(player_no: int, input_type: INPUT_TYPE):
	var button_layout: Dictionary[String, Array]  = get_button_layout(player_no, input_type)
	var layout_path: String
	if input_type == INPUT_TYPE.KEYBOARD:
		layout_path = DEFAULT_KEYBOARD_BUTTON_LAYOUT_PATH
	elif input_type == INPUT_TYPE.GAMEPAD:
		layout_path = DEFAULT_GAMEPAD_BUTTON_LAYOUT_PATH
	var layout_file := FileAccess.open(layout_path, FileAccess.WRITE)
	if !layout_file:
		print("Error saving player button layout as default!")
		return
	layout_file.store_var(button_layout, true)
	layout_file.close()


# Resets a player's button layout to default
func load_default_button_layout(player_no: int, input_type: INPUT_TYPE):
	var default_layout_path: String
	if input_type == INPUT_TYPE.KEYBOARD:
		default_layout_path = DEFAULT_KEYBOARD_BUTTON_LAYOUT_PATH
	elif input_type == INPUT_TYPE.GAMEPAD:
		default_layout_path = DEFAULT_GAMEPAD_BUTTON_LAYOUT_PATH
	var default_layout_file := FileAccess.open(default_layout_path, FileAccess.READ)
	if !default_layout_file:
		print("Error loading default button layout!")
		return {}
	var default_button_layout: Dictionary[String, Array] = default_layout_file.get_var(true)
	set_button_layout(player_no, input_type, default_button_layout)


func clear_button_layouts():
	player_button_layouts.clear()


func get_button_layout(player_no: int, input_type: INPUT_TYPE) -> Dictionary[String, Array]:
	if !player_button_layouts.has(player_no):
		return {}
	if !player_button_layouts[player_no].has(input_type):
		return {}
	return player_button_layouts[player_no][input_type] as Dictionary[String, Array]


func set_button_layout(player_no: int, input_type: INPUT_TYPE, layout: Dictionary[String, Array]):
	if !player_button_layouts.has(player_no):
		player_button_layouts[player_no] = {}
	player_button_layouts[player_no][input_type] = layout


func input_type_to_string(input_type: INPUT_TYPE) -> String:
	if input_type == INPUT_TYPE.GAMEPAD:
		return "Gamepad"
	if input_type == INPUT_TYPE.KEYBOARD:
		return "Keyboard"
	assert(false, "Invalid input type: %s" % [input_type])
	return ""


func get_button_layout_events(player_no: int, input_type: INPUT_TYPE, action: String) -> Array[InputEvent]:
	var events: Array[InputEvent]
	if !player_button_layouts.has(player_no):
		return []
	if !player_button_layouts[player_no].has(input_type):
		return []
	if !player_button_layouts[player_no][input_type].has(action):
		return []
	events.assign(player_button_layouts[player_no][input_type][action] as Array[InputEvent])
	return events


## Creates actions for each player's button layouts using their selected input type.
## Each action will be created as "<action_name>_<player_number>"
func apply_button_layouts() -> void:
	InputMap.load_from_project_settings()
	for action in (GAMEPLAY_ACTIONS + UI_ACTIONS):
		for i in range(MAX_LOCAL_PLAYERS):
			var player_no: int = i + 1
			var player_action: String = action + str(player_no)
			if !InputMap.has_action(player_action):
				InputMap.add_action(player_action)
			else:
				InputMap.action_erase_events(player_action)
			if !player_input_types.has(player_no):
				continue
			var player_input_type: INPUT_TYPE = player_input_types[player_no]
			for event in get_button_layout_events(player_no, player_input_type, action):
				var player_event: InputEvent = event.duplicate()
				if player_input_type == ControlsSettings.INPUT_TYPE.GAMEPAD:
					player_event.device = player_device_ids[player_no]
				InputMap.action_add_event(player_action, player_event)
