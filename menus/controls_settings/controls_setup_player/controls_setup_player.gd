extends Control

@export var player_no: int = 1
@onready var action_container: VBoxContainer = $ScrollContainer/ActionContainer

var device_type = "keyboard" #or "gamepad"
var device_index: int = 0

signal input_pressed


func _ready() -> void:
	load_from_input_map()
	for controls_setup_action in action_container.get_children():
		if controls_setup_action.is_in_group("controls_setup_action"):
			controls_setup_action.connect("request_input_event", _input_event_requested)


func _input_event_requested(controls_setup_node, event_index):
	# Disable all other buttons
	for controls_setup_action in get_all_control_setup_nodes():
		controls_setup_action.set_event_buttons_disabled(true)
			
	# Wait for an input to be pressed
	controls_setup_node.get_event_button(event_index).text = "Press a Button"
	var input_event = await input_pressed
	controls_setup_node.set_input_event(input_event, event_index)
	
	# Re-enable all other buttons
	for controls_setup_action in get_all_control_setup_nodes():
		controls_setup_action.set_event_buttons_disabled(false)
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		input_pressed.emit(event)
	if event is InputEventJoypadMotion:
		input_pressed.emit(event)
	if event is InputEventJoypadButton and event.is_pressed():
		input_pressed.emit(event)


func load_from_input_map():
	for controls_setup_action in get_all_control_setup_nodes():
		controls_setup_action.set_input_events(InputMap.action_get_events(controls_setup_action.action + str(player_no)))


func apply_to_input_map():
	for controls_setup_action in get_all_control_setup_nodes():
		var player_action = controls_setup_action.action + str(player_no)
		if !InputMap.has_action(player_action):
			InputMap.add_action(player_action)
		InputMap.action_erase_events(player_action)
		for event in controls_setup_action.input_events:
			if event != null:
				InputMap.action_add_event(player_action, event)


func get_all_control_setup_nodes() -> Array:
	var nodes := []
	for controls_setup_action in action_container.get_children():
		if controls_setup_action.is_in_group("controls_setup_action"):
			nodes.append(controls_setup_action)
	return nodes
