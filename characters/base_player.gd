extends CharacterBody3D

class_name BattleCharacter

@export var SPEED = 8.0
@export var JUMP_VELOCITY = 4.5
@export var DASH_SPEED = 12.5
@export var AIR_DASH_SPEED = 15
@export var STOCKS = 3
@export var PLAYER = 1
@export var GRAVITY = 25
@export var JUMPFROMGROUND = false
@export var DECELERATION = 1
@export var ACCELERATION = 1
@export var AIR_DECELERATION = 0.25
@export var AIR_ACCELERATION = 0.5
@export var MAX_AIR_DASHES = 1

var facing_direction: Vector2 = Vector2.RIGHT # The last used nonzero move_direction
var attack_direction: int = 1 # The direction for 2-Directional attacks
var moveenabled = false
var deceleration_enabled = true
var limit_speed = true # During normal movement speed is limited, turn this off for stuff like dashing
var air_dashes_used = 0

@onready var Sprite = $PlayerSprite
@onready var animplayer = $PlayerSprite/AnimationPlayer
@onready var state_machine = $StateMachine

#This is crucial for allowing the player to move relative to the camera.
@onready var camera = %CameraRoot/Pivot
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox



func _ready() -> void:
	state_machine.initialize()
	Sprite.billboard = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity.y -= GRAVITY * delta
	move()
	move_and_slide()
	state_machine.advance()


#func setcontrols() -> void:
	#match PLAYER:
		#1:
			#Controlset = load("res://players/player1controls.tres")
		#2:
			#Controlset = load("res://players/player2controls.tres")
		#3:
			#Controlset = load("res://players/player2controls.tres")
		#4:
			#Controlset = load("res://players/player2controls.tres")


func move():
	# Get the player's input direction (the direction they're pressing on keyboard/ control stick)
	var input_dir := get_input_vector()
	# Get the player's movement direction (relative to the camera)
	var movement_dir := get_movement_vector()
	# The player will be facing in the last used movement direction
	if movement_dir != Vector2.ZERO:
		facing_direction = movement_dir
	
	# Set the direction for the hitbox and attacks
	if !is_zero_approx(facing_direction.x):
		attack_direction = sign(facing_direction.x)
		hitbox.scale.x = attack_direction
	
	# The player sprite will be flipped using the input_direction
	# This is because the sprite already faces the camera automatically, and doesn't need the camera's rotation
	if !is_zero_approx(input_dir.x):
		$PlayerSprite.flip_h = (input_dir.x < 0)
	
	# Accelerate the player in the movement direction if they're moving
	# Otherwise decelerate to a stop
	# If movement is disabled, the player will still decelerate
	var acceleration_vector: Vector2
	if is_on_floor():
		acceleration_vector = movement_dir * ACCELERATION
	else:
		acceleration_vector = movement_dir * AIR_ACCELERATION
	
	var deceleration_current = DECELERATION if is_on_floor() else AIR_DECELERATION
		
	if input_dir.x != 0 and moveenabled:
		velocity.x += acceleration_vector.x
		if limit_speed:
			velocity.x = clamp(velocity.x, -SPEED, SPEED)
	elif deceleration_enabled:
		velocity.x = move_toward(velocity.x, 0, deceleration_current)
	
	if input_dir.y != 0 and moveenabled:
		velocity.z += acceleration_vector.y
		if limit_speed:
			velocity.z = clamp(velocity.z, -SPEED, SPEED)
	elif deceleration_enabled:
		velocity.z = move_toward(velocity.z, 0, deceleration_current)


# Input helper function to get input for the current player
# In the future this will also retrieve inputs received over the network (for online play)
func input(action: StringName, type: String = "pressed") -> bool:
	# Gets the correct action based on the player number (ex: attack1, attack2, attack3, etc.)
	var player_action = action + str(PLAYER)
	if !InputMap.has_action(player_action):
		return false
	if type == "pressed":
		return Input.is_action_pressed(player_action)
	if type == "just_pressed":
		return Input.is_action_just_pressed(player_action)
	if type == "just_released":
		return Input.is_action_just_released(player_action)
	return false
	

func get_input_vector() -> Vector2:
	return Vector2(int(input("right")) - int(input("left")), int(input("down")) - int(input("up")))


# Movement vector is the input but rotated relative to the camera
# This allows the player to move in the correct direction no matter how the camera is rotated
func get_movement_vector() -> Vector2:
	return get_input_vector().rotated(camera.rotation.y).normalized()


func _on_hurtbox_hurt(hit_data: HitData, hitbox: Hitbox) -> void:
	state_machine.change_state("Hurt", {hit_data = hit_data})
