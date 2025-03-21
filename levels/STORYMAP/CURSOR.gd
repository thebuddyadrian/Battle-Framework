extends CharacterBody2D


const SPEED = 300.0

@onready var camera = $Camera2D
func _physics_process(delta: float) -> void:


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionx := Input.get_axis("ui_left", "ui_right")
	var directiony := Input.get_axis("ui_up", "ui_down")
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	position.x = clamp(position.x, camera.limit_left, camera.limit_right - 15)
	position.y = clamp(position.y, camera.limit_top -5, camera.limit_bottom - 50)
	
	move_and_slide()
