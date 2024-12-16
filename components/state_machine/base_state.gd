@tool
class_name BaseState
extends Node

const tick_time = 0.016

var root
var parent: StateMachine


func _setup():
	pass


func _end():
	pass


func _enter(data = {}):
	pass


func _step():
	pass


func _step_frozen():
	pass


func _anim_checkpoint(num):
	pass


func _exit(next_state):
	pass


#Overridable method that defines default parameters for the state
func _get_default_data() -> Dictionary:
	return {}


func hit_opponent(hit_def):
	pass


#Shows a warning if this State is not the child of a StateMachine
func _get_configuration_warning():
	var has_state = false
	if get_parent() != null:
		if get_parent().is_in_group("state_machine"):
			return ""
	return "States can only work if they're a child of a StateMachine."

func _save_state():
	return {}


func _load_state(_state: Dictionary):
	pass


# A shortcut to change_state in the parent StateMachine
func change_state(new_state, data := {}):
	parent.change_state(new_state, data)
