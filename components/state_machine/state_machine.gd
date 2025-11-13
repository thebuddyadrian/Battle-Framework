extends Node
class_name StateMachine

#A list of refernces to the child state nodes
var states := {}

#The current active state node
var active_state
var active_params: Array
var previous_state

var state_id := 0 #Counts up every time the state is changed

var state_time := 0 #Counts how many ticks the current state has been active
var sub_state := "" #Used to have states inside of states
var sub_state_time := 0
var is_changing_state = false

# Persistent data that is needed by states
var data := {}

var root: set = set_root

var custom_timers = CustomTimers.new()

@export
var root_node_path: NodePath

signal state_changed(state)


func _ready():
	_setup_states()
	set_root(get_node(root_node_path))
	add_to_group("state_machine")
	
	#Add CustomTimers
	if !has_node("CustomTimers"):
		custom_timers.name = "CustomTimers"
		custom_timers.manual_advance = true
		add_child(custom_timers)
		custom_timers.remove_from_group("network_sync")


func initialize():
	#Change to the first state
	change_state(states.keys()[0])


func reset():
	active_state = null
	previous_state = null
	state_id = 0
	state_time = 0
	sub_state = ""
	sub_state_time = 0
	root = null
	custom_timers.reset()


#Add a reference to all the children inside the states array
func _setup_states():
	for child in get_children():
		if child.name != "CustomTimers":
			#Only add the child if it has a script
			if child.get_script():
				states[child.name] = child
				child.parent = self
			else:
				push_error("State has no script, not adding to array: " + child.name)


func change_state(new_state, data := {}):
	#If the state doesn't exist, push an error.
	if !states.has(new_state):
		push_error("State not found: " + new_state)
		return
	
	is_changing_state = true
	# frame_changed_state = 0#SyncManager.current_tick
	
	#If the current state is not null, end the state
	if active_state != null:
		previous_state = active_state
		active_state._exit(states[new_state])
		active_state._end()
		active_state = null
	
	#Reset state variables
	state_time = 0
	sub_state = ""
	sub_state_time = 0
	
	state_id += 1
	
	#Set up the new state
	active_state = states[new_state]
	active_state._setup()
	state_specific(new_state)
	
	var default_data = {}
	if active_state.has_method("_get_default_data"):
		default_data = active_state._get_default_data()
	
	#Replace empty params with default params
	for key in default_data.keys():
		var value = default_data[key]
		if value == null:
			continue
		if !data.has(key):
			data[key] = default_data[key]
	
	active_state._enter(data)
	is_changing_state = false
	emit_signal("state_changed", active_state)


func advance():
	if active_state != null and !is_changing_state:
		active_state._step()
		state_time += 1 #+ int(Global.fps_30)
		sub_state_time += 1 #+ int(Global.fps_30)
	custom_timers.advance_timers()


func make_timer(func_name:String, time, node = self, params:Array=[], ignore_freeze = false):
	if time == 0:
		node.callv(func_name, params)
	var new_params = [func_name, state_id, active_state.name, get_path_to(node), params.duplicate(true)]
	custom_timers.make_timer("check_timer", time, self, new_params, ignore_freeze)


func cancel_timer(func_name: String):
	for timer_name in custom_timers.timers.keys():
		var timer = custom_timers.timers[timer_name]
		if timer[2][0] == func_name:
			custom_timers.timers.erase(timer_name)


func get_timer_time(func_name: String, get_shortest = true):
	var timer_time = INF
	if !get_shortest: timer_time = 0
	for timer_name in custom_timers.timers.keys():
		var timer = custom_timers.timers[timer_name]
		if timer[2][0] == func_name:
			var new_time = timer[0]
			if (get_shortest and new_time < timer_time) or (!get_shortest and new_time > timer_time):
				timer_time = new_time
	return timer_time
	


#Makes sure the timer doesn't fire off after the state has changed
func check_timer(func_name, old_id, state_fired_name, node_path, params):
	#Used to prevent a timer from firing after the state has already been changed.
	#and if the state id when the timer was started (old_id) is the same as the current state id (state_id)
	#Used for rare cases where a timer is created, and the state is changed and is quickly
	#changed back before the timer ends, detecting the same state but a different ID
	if get_active_state_name() == state_fired_name and state_id == old_id and !is_changing_state:
		get_node(node_path).callv(func_name, params)


func change_sub_state(new_state: String):
	sub_state_time = 0
	sub_state = new_state


func state_specific(new_state):
	pass


func set_root(new_root: Node):
	root = new_root
	for state_node in states.values():
		state_node.root = new_root


func get_active_state_name() -> String:
	if active_state == null:
		return ""
	return active_state.name

# ROLLBACK STUFF LEFTOVER FROM MY OTHER PROJECT - IGNORE - thebuddyadrian

func _save_state() -> Dictionary:
	var state = {
		state_id = state_id,
		state_time = state_time,
		sub_state = sub_state,
		sub_state_time = sub_state_time,
		is_changing_state = is_changing_state,
		timer_state = custom_timers._save_state().duplicate(true),
		data = data.duplicate(true),
	}
	
	if active_state != null:
		state["active_state"] = active_state.name
	
		if active_state.has_method("_save_state") and !active_state.is_in_group("network_sync"):
			state["active_state_data"] = active_state._save_state().duplicate(true)
	
#	state["persistent_state_data"] = {}
	
#	for state_name in states.keys():
#		var state_node = states[state_name]
#		if state_node.has_method("_save_state_persistent"):
#			state["persistent_state_data"][state_name] = state_node._save_state_persistent().duplicate(true)
	
	if previous_state:
		state["previous_state"] = previous_state.name
	
	return state
	

func _load_state(state: Dictionary):
	if state.has("active_state"):
		active_state = states[state["active_state"]]
	else:
		active_state = null
	if state.has("previous_state"):
		previous_state = states[state["previous_state"]]
	else:
		previous_state = null
	
	if state.has("active_state_data"):
		if active_state != null:
			active_state._load_state(state["active_state_data"])
	
	if state.has("persistent_state_data"):
		for state_name in state["persistent_state_data"].keys():
			var state_data = state["persistent_state_data"][state_name]
			states[state_name]._load_state_persistent(state_data)
	
	state_id = state["state_id"]
	state_time = state["state_time"]
	sub_state = state["sub_state"]
	sub_state_time = state["sub_state_time"]
	is_changing_state = state["is_changing_state"]
	custom_timers._load_state(state["timer_state"])
	data = state["data"].duplicate(true)
