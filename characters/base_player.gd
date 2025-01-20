extends CharacterBody3D

class_name BattleCharacter

@export var SPEED = 8.0
@export var JUMP_VELOCITY = 11.0
@export var DASH_SPEED = 12.5
@export var AIR_DASH_SPEED = 15
@export var STOCKS = 3
@export var PLAYER = 1
@export var GRAVITY = 0.5
@export var JUMPFROMGROUND = false
@export var DECELERATION = 0.75
@export var ACCELERATION = 0.8
@export var AIR_DECELERATION = 0.25
@export var AIR_ACCELERATION = 0.5
@export var MAX_AIR_DASHES = 1

## The last used nonzero move_direction, used for dashing, air dashing, and four directional attacks
## This is set automatically during movement
var facing_direction: Vector2 = Vector2.RIGHT
## The direction for 2-Directional attacks and for the sprite
## This is NOT set automatically, and must be updated manually by calling "update_facing_direction_2d()"
var facing_direction_2d: int = 1
var moveenabled = false
var deceleration_enabled = true
var limit_speed = true # During normal movement speed is limited, turn this off for stuff like dashing
var air_dashes_used = 0
var acceleration_scale: float = 1
var deceleration_scale: float = 1
var gravity_scale: float = 1

@onready var Sprite = $PlayerSprite
@onready var animplayer: AnimationPlayer = $PlayerSprite/AnimationPlayer
@onready var state_machine = $StateMachine

#This is crucial for allowing the player to move relative to the camera.
@onready var camera = %CameraRoot/Pivot
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox



func _ready() -> void:
	state_machine.initialize()
	Sprite.billboard = true


func _physics_process(_delta: float) -> void:
	# Add the gravity.
	velocity.y -= GRAVITY * gravity_scale
	_process_movement()
	#_process_actions()
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

#
func _process_movement():
	# Get the player's input direction (the direction they're pressing on keyboard/ control stick)
	var input_dir := get_input_vector()
	# Get the player's movement direction (relative to the camera)
	var movement_dir := get_movement_vector()
	
	# The player will be facing in the last used movement direction
	if movement_dir != Vector2.ZERO:
		facing_direction = movement_dir
	
	# Accelerate the player in the movement direction if they're moving
	# Otherwise decelerate to a stop
	# If movement is disabled, the player will still decelerate
	var acceleration_vector: Vector2
	if is_on_floor():
		acceleration_vector = movement_dir * ACCELERATION * acceleration_scale
	else:
		acceleration_vector = movement_dir * AIR_ACCELERATION * acceleration_scale
	
	var deceleration_current = DECELERATION if is_on_floor() else AIR_DECELERATION
	deceleration_current *= deceleration_scale
	
	if !is_zero_approx(input_dir.x) and moveenabled:
		velocity.x += acceleration_vector.x
		if limit_speed:
			velocity.x = clamp(velocity.x, -SPEED, SPEED)
	elif deceleration_enabled:
		velocity.x = move_toward(velocity.x, 0, deceleration_current)
	
	if !is_zero_approx(input_dir.y) and moveenabled:
		velocity.z += acceleration_vector.y
		if limit_speed:
			velocity.z = clamp(velocity.z, -SPEED, SPEED)
	elif deceleration_enabled:
		velocity.z = move_toward(velocity.z, 0, deceleration_current)


# Updates the 2d direction to match the input
# This must be called manually, because we only want to update this in specific situations, like attacking or turning around
func update_facing_direction_2d():
	if !is_zero_approx(get_input_vector().x):
		# The player sprite will be flipped using the input_direction
		# This is because the sprite already faces the camera automatically, and doesn't need the camera's rotation
		$PlayerSprite.flip_h = (get_input_vector().x < 0)
		
		# Set the direction for the hitbox and attacks
		facing_direction_2d = sign(get_movement_vector().x)


# Force the player to face a specific direction
func set_facing_direction_2d(direction: int):
	# Set facing direction relative to the camera
	var vec: Vector2 = Vector2(direction, 0).rotated(-camera.rotation.y)
	$PlayerSprite.flip_h = (direction < 0)
	facing_direction_2d = sign(vec.x)
	


func is_turning() -> bool:
	return sign(get_movement_vector().x) != facing_direction_2d and !is_zero_approx(get_movement_vector().x)


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
