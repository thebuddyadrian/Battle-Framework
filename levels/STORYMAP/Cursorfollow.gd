extends CharacterBody2D


const SPEED = 160.0

#@onready var camera = $Camera2D
@export var cursor:CharacterBody2D
func _physics_process(delta: float) -> void:


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if global_position.distance_to(cursor.global_position ) > 5:
		position.x = move_toward(global_position.x, cursor.global_position.x,SPEED * delta)
		position.y = move_toward(global_position.y, cursor.global_position.y,SPEED * delta)
	
	#position.x = clamp(position.x, camera.limit_left + 270, camera.limit_right + 220)
	#position.y = clamp(position.y, camera.limit_top - 15, camera.limit_bottom - 50)
	
	move_and_slide()
