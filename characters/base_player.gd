extends CharacterBody3D

class_name BattleCharacter


@export var SPEED = 8.0
@export var JUMP_VELOCITY = 4.5
@export var DASH_SPEED = 12.0
@export var STOCKS = 3
@export var PLAYER = 1
@export var GRAVITY = 5
@export var JUMPFROMGROUND = false
var dirget = 1

@export var Controlset = MoonCastControlSettings.new()

@onready var Sprite = $PlayerSprite
@onready var animplayer = $PlayerSprite/AnimationPlayer
@onready var state_machine = $StateMachine

#This is crucial for allowing the player to move relative to the camera.
@onready var camera = %CameraRoot/Pivot


func _ready() -> void:
	state_machine.initialize()


func _physics_process(delta: float) -> void:
	
	setcontrols()
	
	
	# Add the gravity.
	velocity.y -= GRAVITY * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector(Controlset.direction_left, Controlset.direction_right, Controlset.direction_up, Controlset.direction_down)
	var input_dirVisual := Input.get_vector(Controlset.direction_left, Controlset.direction_right, Controlset.direction_down, Controlset.direction_up)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	
	if !is_zero_approx(direction.x):
		Sprite.flip_h = direction.x < 0
		
	if direction.x != 0:
		dirget = direction.x
	if direction:
		var imaginary = (input_dirVisual.angle() + deg_to_rad(90)) + camera.rotation.y
		var horizontal_velocity = Vector3(0, 0, SPEED).rotated(Vector3.UP, imaginary);	
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	state_machine.advance()


func setcontrols() -> void:
	match PLAYER:
		1:
			Controlset = load("res://players/player1controls.tres")
		2:
			Controlset = load("res://players/player2controls.tres")
		3:
			Controlset = load("res://players/player2controls.tres")
		4:
			Controlset = load("res://players/player2controls.tres")
