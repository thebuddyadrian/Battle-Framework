extends Node

const devmenu_packed_scene:PackedScene = preload("res://menus/dev_menu.tscn")

var devmenu_gui:CanvasLayer

var debug_mode:bool = true

var mouse_mode_stack:Dictionary[int, int] = {}

var delayed_calls:Dictionary[int, Dictionary] = {}

func inject_dev_menu() -> void:
	if not is_instance_valid(devmenu_gui):
		devmenu_gui = devmenu_packed_scene.instantiate()
	
	if not devmenu_gui.is_inside_tree():
		var tree:SceneTree = get_tree()
		
		if is_instance_valid(tree.current_scene):
			get_tree().current_scene.add_child(devmenu_gui)

func begin_mouse_mode_override(mouse_mode: Input.MouseMode) -> int:
	var key:int = randi()
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
func delay(function: Callable, time:float = 1, repeat:int = 0) -> Dictionary:
	var key:int = randi()
	while key in delayed_calls: key = randi()
	var data:Dictionary[String, Variant] = {
		"start_time": time,
		"time": time,
		"function": function,
		"repeat": repeat
	}
	delayed_calls[key] = data
	return {"err": OK, "key": key, "data": data}

## Cancel a delay and returns delay data, including `err`.
func cancel_delay(key: int) -> Dictionary:
	if !(key in delayed_calls.keys()): return {"err": ERR_DOES_NOT_EXIST}
	var out := {"err": OK, "data": delayed_calls[key]}
	delayed_calls.erase(key)
	return out

func _process(delta:float) -> void:
	for key in delayed_calls.keys():
		var val:Dictionary = delayed_calls[key]
		if !is_instance_valid(val.function.get_object()):
			delayed_calls.erase(key)
			continue
		
		val.time -= delta
		if val.time <= 0:
			val.function.call()
			if val.repeat == 0: delayed_calls.erase(key)
			else: val.repeat -= 1; val.time = val.start_time
	
	inject_dev_menu() #not the most performant way of doing this, but meh
	return

func _notification(what:int) -> void:
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			if len(mouse_mode_stack) > 0:
				Input.mouse_mode = mouse_mode_stack.values()[-1]
	return
