extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_left_pressed() -> void:
	Input.action_press("left1", 1.0)
	Input.action_press("ui_left", 1.0)
	pass # Replace with function body.


func _on_left_released() -> void:
	Input.action_release("left1")
	Input.action_release("ui_left")
	pass # Replace with function body.


func _on_right_pressed() -> void:
	Input.action_press("right1", 1.0)
	Input.action_press("ui_right", 1.0)
	pass # Replace with function body.


func _on_right_released() -> void:
	Input.action_release("right1")
	Input.action_release("ui_right")
	pass # Replace with function body.
