extends Control

@onready var gamepad_controls: Control = $gamepad
@onready var overlay_controls: Control = $"overlay controls"

@onready var gamepad_visible: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func toggle_gamepad_visibility() -> void:
	gamepad_visible = !gamepad_visible
	gamepad_controls.visible = gamepad_visible
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


func _on_toggle_hide_show_pressed() -> void:
	toggle_gamepad_visibility()
	pass # Replace with function body.

func _on_toggle_hide_show_released() -> void:
	pass # Replace with function body.



func _on_a_pressed() -> void:
	Input.action_press("jump1", 1.0)
	Input.action_press("ui_accept", 1.0)
	pass # Replace with function body.


func _on_a_released() -> void:
	Input.action_release("jump1")
	Input.action_release("ui_accept")
	pass # Replace with function body.


func _on_b_pressed() -> void:
	Input.action_press("attack1", 1.0)
	Input.action_press("ui_cancel", 1.0)
	pass # Replace with function body.


func _on_b_released() -> void:
	Input.action_release("attack1")
	Input.action_release("ui_cancel")
	pass # Replace with function body.


func _on_start_pressed() -> void:
	Input.action_press("pause1", 1.0)
	pass # Replace with function body.


func _on_start_released() -> void:
	Input.action_release("pause1")
	pass # Replace with function body.


func _on_select_pressed() -> void:
	Input.action_press("option1", 1.0)
	pass # Replace with function body.


func _on_select_released() -> void:
	Input.action_release("option1")
	pass # Replace with function body.


func _on_c_pressed() -> void:
	Input.action_press("guard1",1.0)
	pass # Replace with function body.

func _on_c_released() -> void:
	Input.action_release("guard1")
	pass # Replace with function body.

func _on_d_pressed() -> void:
	Input.action_press("skill1",1.0)
	pass # Replace with function body.

func _on_d_released() -> void:
	Input.action_release("skill1")
	pass # Replace with function body.
	
func _on_e_pressed() -> void:
	Input.action_press("dash1",1.0)
	pass # Replace with function body.


func _on_e_released() -> void:
	Input.action_release("dash1")
	pass # Replace with function body.


func _on_up_pressed() -> void:
	Input.action_press("up1", 1.0)
	Input.action_press("ui_up", 1.0)
	pass # Replace with function body.


func _on_up_released() -> void:
	Input.action_release("up1")
	Input.action_release("ui_up")
	pass # Replace with function body.


func _on_down_pressed() -> void:
	Input.action_press("down1", 1.0)
	Input.action_press("ui_up", 1.0)
	pass # Replace with function body.


func _on_down_released() -> void:
	Input.action_release("down1")
	Input.action_release("ui_down")
	pass # Replace with function body.
