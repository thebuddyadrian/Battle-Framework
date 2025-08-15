extends Control



@export var player_no: int = 1
@onready var action_container: VBoxContainer = $ScrollContainer/ActionContainer
@onready var device_dropdown: OptionButton = $ScrollContainer/ActionContainer/InputDevice/DeviceDropdown

var device_type = "keyboard" #or "gamepad"
var device_index: int = 0
# A dictionary that maps the indices of the DeviceDropdown node to the devices indicies of the connected devices
# They will always be off from the actual indices since the "Keyboard" option is first then the gamepads
var dropdown_index_to_device_index = {}

signal input_pressed


func _ready() -> void:
	initialize()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func initialize():
	update_device_dropdown()
	load_from_input_map()
	for controls_setup_action in action_container.get_children():
		if controls_setup_action.is_in_group("controls_setup_action"):
			controls_setup_action.connect("request_input_event", _input_event_requested)

func _set_all_event_buttons_disabled(p_disabled: bool):
	for controls_setup_action in get_all_control_setup_nodes():
		controls_setup_action.set_event_buttons_disabled(p_disabled)


func _input_event_requested(controls_setup_node, event_index):
	# Disable all other buttons
	_set_all_event_buttons_disabled(true)
			
	# Wait for an input to be pressed
	controls_setup_node.get_event_button(event_index).text = "Listening... (DEL to Clear)"
	var input_event = await input_pressed
	controls_setup_node.set_input_event(input_event, event_index)
	
	# Re-enable all other buttons
	_set_all_event_buttons_disabled(false)
	

func _input(event: InputEvent) -> void:
	# For deleting binds
	if event is InputEventKey:
		if event.keycode == KEY_DELETE:
			input_pressed.emit(null)
			return
	if event is InputEventKey and event.is_pressed() and device_type == "keyboard":
		input_pressed.emit(event)
	if device_type == "gamepad":
		if event.device != device_index:
			return
		if event is InputEventJoypadMotion:
			if abs(event.axis_value) > 0.75:
				input_pressed.emit(event)
				return
		if event is InputEventJoypadButton:
			input_pressed.emit(event)
			return


func _on_joy_connection_changed(_device, _connected):
	update_device_dropdown()


func load_from_input_map():
	for controls_setup_action in get_all_control_setup_nodes():
		var valid_events = []
		for event in InputMap.action_get_events(controls_setup_action.action + str(player_no)):
			if device_type == "gamepad" and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
				valid_events.append(event)
			elif device_type == "keyboard" and event is InputEventKey:
				valid_events.append(event)
		controls_setup_action.set_input_events(valid_events)


func update_device_dropdown():
	device_dropdown.clear()

	# Add "Keyboard" option first, make the ID a high number so it doesn't conflict with gamepads
	device_dropdown.add_item("Keyboard", ControlsSettings.KEYBOARD_DEVICE_INDEX)

	# Add gamepads
	for joypad in Input.get_connected_joypads():
		var joypad_name: String = Input.get_joy_name(joypad)
		device_dropdown.add_item(str(joypad) + ": " + joypad_name, joypad)
	
	update_device_index()


func update_device_index():
	# Load the currently selected device index
	device_index = ControlsSettings.player_device_indicies.get(player_no, ControlsSettings.KEYBOARD_DEVICE_INDEX)
	device_dropdown.select(device_dropdown.get_item_index(device_index))
	device_type = "keyboard" if device_index == ControlsSettings.KEYBOARD_DEVICE_INDEX else "gamepad"

	load_from_input_map()


func apply_to_input_map():
	for controls_setup_action in get_all_control_setup_nodes():
		var player_action = controls_setup_action.action + str(player_no)
		if !InputMap.has_action(player_action):
			InputMap.add_action(player_action)
		InputMap.action_erase_events(player_action)
		for event in controls_setup_action.input_events:
			if event != null:
				var modified_event = event.duplicate()
				# Force the device index of the event to be the correct one selected by the dropdown
				if modified_event is InputEventJoypadButton or modified_event is InputEventJoypadMotion:
					modified_event.device = device_index
				InputMap.action_add_event(player_action, modified_event)


func get_all_control_setup_nodes() -> Array:
	var nodes := []
	for controls_setup_action in action_container.get_children():
		if controls_setup_action.is_in_group("controls_setup_action"):
			nodes.append(controls_setup_action)
	return nodes


func _on_detect_button_pressed() -> void:
	pass # Replace with function body.


func _on_device_dropdown_pressed() -> void:
	pass # Replace with function body.


func _on_device_dropdown_item_selected(index:int) -> void:
	ControlsSettings.player_device_indicies[player_no] = device_dropdown.get_item_id(index)
	update_device_index()
