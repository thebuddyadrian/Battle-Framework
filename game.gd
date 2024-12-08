extends Node


var debug_mode := true
var debug_options := {
	"esc_quit": true,
}

var mouse_mode_stack := {}

var delayed_calls := {}


enum ERR {
	OK,
	VALUE,
	TYPE,
	NOT_FOUND,
	DUPLICATE,
}


func begin_mouse_mode_override(mouse_mode: Input.MouseMode) -> int:
	var key := randi()
	while key in mouse_mode_stack: key = randi()
	mouse_mode_stack[key] = mouse_mode
	Input.mouse_mode = mouse_mode
	return key

func end_mouse_mode_override(index: int):
	mouse_mode_stack.erase(index)
	if len(mouse_mode_stack) == 0: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else: Input.mouse_mode = mouse_mode_stack.values()[-1]
	return


## Delay a function call.
## Delays by frames if `time` is int or seconds if `time` is float.
## Returns `err`, `key` and `data`.
## Set `repeat` to repeat multiple times. <0 means infinite repeats.
func delay(function: Callable, time = 1, repeat := 0) -> Dictionary:
	if not typeof(time) in [TYPE_INT, TYPE_FLOAT]:
		assert(false); return {"err": ERR.TYPE}
	var key := randi()
	while key in delayed_calls: key = randi()
	var data := {
		"start_time": time,
		"time": time,
		"function": function,
		"repeat": repeat
	}
	delayed_calls[key] = data
	return {"err": ERR.OK, "key": key, "data": data}

## Cancel a delay and returns delay data, including `err`.
func cancel_delay(key: int) -> Dictionary:
	if !(key in delayed_calls.keys()): return {"err": ERR.NOT_FOUND}
	var out := {"err": ERR.OK, "data": delayed_calls[key]}
	delayed_calls.erase(key)
	return out


func _process(delta):
	for key in delayed_calls.keys():
		var val = delayed_calls[key]
		if !is_instance_valid(val.function.get_object()):
			delayed_calls.erase(key)
			continue
		
		val.time -= delta if typeof(val.time) == TYPE_FLOAT else 1
		if val.time <= 0:
			val.function.call()
			if val.repeat == 0: delayed_calls.erase(key)
			else: val.repeat -= 1; val.time = val.start_time
	return


func _notification(what):
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			if len(mouse_mode_stack) > 0:
				Input.mouse_mode = mouse_mode_stack.values()[-1]
	return


func _input(event):
	if debug_mode and debug_options.esc_quit:
		if event is InputEventKey:
			if event.keycode == KEY_ESCAPE and event.pressed:
				get_tree().quit()
	return
