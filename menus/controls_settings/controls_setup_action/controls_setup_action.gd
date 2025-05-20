@tool
extends Control

@export var action = ""
@export var text = ""
@export var description = ""

#Used to distinguish multiple instances of ControlsSetupAction 
#with the same action
var temp_index = 0 
var input_events = [null, null] : set = set_input_events

@onready var action_label = $HBoxContainer/ActionLabel
#@onready var action_pressed_display = $ActionPressedDisplay
@onready var event_button_1 = $HBoxContainer/EventButton1
@onready var event_button_2 = $HBoxContainer/EventButton2

signal request_input_event (self_node, index)
signal description_hint (desc)

func _enter_tree():
	input_events.resize(2)

func _ready():
	_update_text()
	update_input_icons()


func _process(delta):
	if Engine.is_editor_hint():
		_update_text()
	
	#Highlight this action if one of the events is pressed
#	if InputMap.has_action(get_temp_action(action)):
#		action_pressed_display.visible = Input.is_action_pressed(get_temp_action(action))


func _update_text():
	action_label.text = text


#When pressed, the main ControlsSetup will catch this signal and prompt for a button press
func _on_SetActionButton_pressed():
	emit_signal("request_input_event", self)



func set_input_event(event: InputEvent, index: int):
	input_events[index] = event
	set_input_events(input_events)


func set_input_events(p_events):
	input_events = p_events.duplicate()
	if event_button_1:
		update_input_icons()


func get_event_button(button_index: int):
	assert(button_index == 0 or button_index == 1, "Invalid event button index. Must be 0 or 1")
	if button_index == 0:
		return event_button_1
	if button_index == 1:
		return event_button_2


#Converts an analog joypad motion into a digital one by either making it zero
#if its below the deadzone or setting it to the deadzone.
func convert_joypad_motion_to_digital(joypad_motion: InputEventJoypadMotion, deadzone = 0.5) -> InputEventJoypadMotion:
	var new_joypad_motion = joypad_motion.duplicate(true)
	if abs(joypad_motion.axis_value) < deadzone:
		new_joypad_motion.axis_value = 0.0
	else:
		if joypad_motion.axis_value > 0:
			new_joypad_motion.axis_value = 1
		else:
			new_joypad_motion.axis_value = -1
	return new_joypad_motion


func input_event_to_text(event) -> String:
	if event is InputEventKey:
		return event.as_text()
	
	if event is InputEventJoypadButton:
		return "Pad Button " + str(event.button_index)
	
	if event is InputEventJoypadMotion:
		event = convert_joypad_motion_to_digital(event)
		return "Pad Axis " + str(event.axis) + ": " + str(event.axis_value)
	
	return ""


func get_temp_action(action: String) -> String:
	return "temp_" + action + str(temp_index)


func update_input_icons():
	input_events.resize(2)
	if input_events[0]:
		event_button_1.text = input_event_to_text(input_events[0])
		#event_button_1.icon = ControllerIcons.parse_event(input_events[0])
	else:
		event_button_1.text = "---"
		#event_button_1.icon = null
	if input_events[1]:
		event_button_2.text = input_event_to_text(input_events[1])
		#event_button_2.icon = ControllerIcons.parse_event(input_events[1])
	else:
		event_button_2.text = "---"
		event_button_2.icon = null
#	event_icon_1.path = ["joypad/left", "joypad/right"]
#	event_icon_2.path = get_temp_action(action)
#	ControllerIcons.refresh()


func set_event_buttons_disabled(p_disabled: bool):
	event_button_1.disabled = p_disabled
	event_button_2.disabled = p_disabled


#Show a description on the main ControlsSetup scene when mouse over
func _on_SetActionButton_mouse_entered():
	emit_signal("description_hint", description)
	pass # Replace with function body.


#Clear the description on the main ControlsSetup scene when mouse exit
func _on_SetActionButton_mouse_exited():
	emit_signal("description_hint", "")
	pass # Replace with function body.


func _on_event_button_1_pressed() -> void:
	emit_signal("request_input_event", self, 0)


func _on_event_button_2_pressed() -> void:
	emit_signal("request_input_event", self, 1)
