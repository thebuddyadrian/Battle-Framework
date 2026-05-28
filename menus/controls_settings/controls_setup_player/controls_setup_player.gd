extends Control

## Defines which device ID will be read as the keyboard. Set to a high number to not conflict
## with gamepad device IDs.
const KEYBOARD_DEVICE_ID: int = 999

@export var player_no: int = 1
@onready var action_container: VBoxContainer = $ScrollContainer/ActionContainer
@onready var device_dropdown: OptionButton = $ScrollContainer/ActionContainer/InputDevice/DeviceDropdown
@onready var set_as_default_button: Button = $ScrollContainer/ActionContainer/SetAsDefault

var input_type: ControlsSettings.INPUT_TYPE
var device_id: int = 0
# A dictionary that maps the indices of the DeviceDropdown node to the devices indicies of the connected devices
# They will always be off from the actual indices since the "Keyboard" option is first then the gamepads
var dropdown_index_to_device_index = {}

signal input_pressed


func _ready() -> void:
	initialize()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	if !OS.has_feature("standalone"):
		# Allow setting a button layout as default in debugger only, not in exported builds
		set_as_default_button.show()


func initialize():
	update_device_dropdown()
	load_from_controls_settings()
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
	if input_type == ControlsSettings.INPUT_TYPE.KEYBOARD:
		if event is InputEventKey and event.is_pressed():
			input_pressed.emit(event)
	if input_type == ControlsSettings.INPUT_TYPE.GAMEPAD:
		if event.device != device_id:
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


func update_device_dropdown():
	device_dropdown.clear()

	# Add "Keyboard" option first, make the ID a high number so it doesn't conflict with gamepads
	device_dropdown.add_item("Keyboard", KEYBOARD_DEVICE_ID)

	# Add gamepads
	for joypad in Input.get_connected_joypads():
		var joypad_name: String = Input.get_joy_name(joypad)
		device_dropdown.add_item(str(joypad) + ": " + joypad_name, joypad)
	
	update_device_index()


func update_device_index():
	# Load the currently selected device index
	device_id = ControlsSettings.player_device_ids.get(player_no, 0)
	device_dropdown.select(device_dropdown.get_item_index(device_id))
	if device_id == KEYBOARD_DEVICE_ID:
		input_type = ControlsSettings.INPUT_TYPE.KEYBOARD
	else:
		input_type = ControlsSettings.INPUT_TYPE.GAMEPAD
	load_from_controls_settings()


func load_from_controls_settings():
	for controls_setup_action in get_all_control_setup_nodes():
		var action: String = controls_setup_action.action
		controls_setup_action.set_input_events(
				ControlsSettings.get_button_layout_events(player_no, input_type, action))


func apply_to_controls_settings():
	var layout: Dictionary[String, Array]
	for controls_setup_action in get_all_control_setup_nodes():
		var action: String = controls_setup_action.action
		layout[action] = []
		for event in controls_setup_action.input_events:
			if event != null:
				var modified_event: InputEvent = event.duplicate()
				# Force the device index of the event to be the correct one selected by the dropdown
				if modified_event is InputEventJoypadButton or modified_event is InputEventJoypadMotion:
					modified_event.device = device_id
				layout[action].append(modified_event)
	ControlsSettings.set_button_layout(player_no, input_type, layout)
	ControlsSettings.player_input_types[player_no] = input_type
	ControlsSettings.player_device_ids[player_no] = device_id
				

func get_all_control_setup_nodes() -> Array:
	var nodes := []
	for controls_setup_action in action_container.get_children():
		if controls_setup_action.is_in_group("controls_setup_action"):
			nodes.append(controls_setup_action)
	return nodes


func _on_detect_button_pressed() -> void:
	pass # Replace with function body.


func _on_device_dropdown_item_selected(index:int) -> void:
	ControlsSettings.player_device_ids[player_no] = device_dropdown.get_item_id(index)
	update_device_index()


func _on_reset_to_default_pressed() -> void:
	ControlsSettings.load_default_button_layout(player_no, input_type)
	initialize()


func _on_set_as_default_pressed() -> void:
	apply_to_controls_settings()
	ControlsSettings.save_button_layout_as_default(player_no, input_type)
