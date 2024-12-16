extends Node
class_name CustomTimers

var timers = {}
var freeze = false
var timer_id = 0
var manual_advance = false


func _ready():
	add_to_group("network_sync")


func _network_process(_input):
	if manual_advance: return
	advance_timers()
	
	
func reset():
	timers = {}
	freeze = false
	timer_id = 0


func advance_timers():
	for key in timers.keys():
		if !timers.has(key):
			continue
		if timers[key][3] == false and freeze == false:
			#if Global.fps_30:
				#timers[key][0] = max(timers[key][0]-2,0)
			#else:
			if true:
				timers[key][0] = max(timers[key][0]-1,0)
		if timers[key][0] <= 0:
			call_timer_func(timers[key][4],timers[key][1],timers[key][2])
			timers.erase(key)


func sort_timers():
	var timer_keys = timers.keys()
	timer_keys.sort()
	var timers_sorted = {}
	for timer_key in timer_keys:
		timers_sorted[timer_key] = timers[timer_key]
	timers = timers_sorted.duplicate(true)


# Adds a timer to the dictionary
func make_timer(func_name:String, time, node = self, params:Array=[], ignore_freeze = false):
	timer_id += 1
	timers[func_name+str(timer_id)] = [time, get_path_to(node), params, ignore_freeze, func_name]
	sort_timers()


# Calls the function associated with the timer
func call_timer_func(func_name, node_path, params):
	get_node(node_path).callv(func_name,params)


# Removes all timers corresponding to the given function
func cancel_timer(func_name: String):
	for timer_name in timers.keys():
		var timer = timers[timer_name]
		if timer[4] == func_name:
			timers.erase(timer_name)


# Get the amount of time left for a given timer
# If multiple timers are assigned to a certain function
# Get the shortest or longest
func get_timer_time(func_name: String, get_shortest = true):
	var timer_time = INF
	if !get_shortest: timer_time = 0
	for timer_name in timers.keys():
		var timer = timers[timer_name]
		if timer[4] == func_name:
			var new_time = timer [0]
			if (get_shortest and new_time < timer_time) or (!get_shortest and new_time > timer_time):
				timer_time = new_time
	return timer_time


func _save_state() -> Dictionary:
	return {
		timers = timers.duplicate(true),
		freeze = freeze,
		timer_id = timer_id,
	}


func _load_state(state: Dictionary):
	timers = state["timers"].duplicate(true)
	freeze = state["freeze"]
	timer_id = state["timer_id"]
