extends CharacterBody3D
class_name BattleCharacter

@export var SPEED = 8.0
@export var JUMP_VELOCITY = 13.0
@export var DASH_SPEED = 12.5
@export var AIR_DASH_SPEED = 15
@export var STOCKS = 3
@export var HP = 300
@export var MP = 300
@export var player_id = 1
@export var GRAVITY = 0.65
@export var FALL_SPEED = 12
@export var JUMPFROMGROUND = false
@export var DECELERATION = 0.75
@export var ACCELERATION = 0.8
@export var AIR_DECELERATION = 0.15
@export var AIR_ACCELERATION = 0.5
@export var MAX_AIR_DASHES = 1

@export var IS_CLIENTSIDE = false


## How many frames the player has to press the attack button after inputting a direction to do a heavy/upper attack
var HEAVY_DIRECTION_INPUT_WINDOW: int = 8
var UPPER_DIRECTION_INPUT_WINDOW: int = 4

var current_hp: int = HP
## The last used nonzero move_direction, used for dashing, air dashing, and four directional attacks
## This is set automatically during movement
var facing_direction: Vector2 = Vector2.RIGHT
## The direction for 2-Directional attacks and for the sprite
## This is NOT set automatically, and must be updated manually by calling "update_facing_direction_2d()" and other similar functions
var facing_direction_2d: int = 1
var deceleration_enabled = true
var limit_speed = true # During normal movement speed is limited, turn this off for stuff like dashing
var air_dashes_used = 0
## Used to temporarily make acceleration faster or slower
var acceleration_scale: float = 1
var deceleration_scale: float = 1
var gravity_scale: float = 1
var actions_enabled: Array[String]
## A dictionary of directions that were recently pressed to input a heavy attack
var heavy_direction_inputs: Dictionary = {}
## Same but for upper
var upper_direction_inputs: Dictionary = {}
var most_recent_direction_input: String = "right"
var VALID_ACTIONS = ["move", "jump", "dash", "air_dash", "attack", "skill", "guard", "heal"]
# Keep track of the last player you hit
var last_hit_player: BattleCharacter

@onready var Sprite = $PlayerSprite
@onready var animplayer: AnimationPlayer = $PlayerSprite/AnimationPlayer
@onready var state_machine = $StateMachine

#This is crucial for allowing the player to move relative to the camera.
var camera: Node3D
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox




func _ready() -> void:
	state_machine.initialize()
	Sprite.billboard = true
	if player_id == 1:
		IS_CLIENTSIDE = true
	if IS_CLIENTSIDE == true:
		Globals.CLIENTSIDE_PLAYER = self


func _physics_process(_delta: float) -> void:
	# When buttons get pressed, save them in a dictionary to know if a heavy attack was inputted
	# Count down every frame until the heavy input window runs out, then remove them
	for direction in heavy_direction_inputs:
		if heavy_direction_inputs[direction] == 0 or !input(direction, "pressed"):
			heavy_direction_inputs.erase(direction)
		else:
			heavy_direction_inputs[direction] -= 1
	
	for direction in upper_direction_inputs:
		if upper_direction_inputs[direction] == 0 or !input(direction, "pressed"):
			upper_direction_inputs.erase(direction)
		else:
			upper_direction_inputs[direction] -= 1
	
	for direction in ["left", "right", "up", "down"]:
		if input(direction, "just_pressed"):
			most_recent_direction_input = direction
			heavy_direction_inputs[direction] = HEAVY_DIRECTION_INPUT_WINDOW
			upper_direction_inputs[direction] = UPPER_DIRECTION_INPUT_WINDOW
	
	if camera.rotation_degrees.y >= 170:
		$PlayerSprite.flip_h = facing_direction_2d >= 0
	else:
		$PlayerSprite.flip_h = facing_direction_2d < 0
	
	# Test Hud
	$TestLabel.text = "HP: %s" % str(current_hp)

	# Add the gravity.
	if velocity.y >  -FALL_SPEED:
		velocity.y -= GRAVITY * gravity_scale
	
	_process_movement()
	_process_actions()
	move_and_slide()
	state_machine.advance()


#func setcontrols() -> void:
	#match player_id:
		#1:
			#Controlset = load("res://players/player1controls.tres")
		#2:
			#Controlset = load("res://players/player2controls.tres")
		#3:
			#Controlset = load("res://players/player2controls.tres")
		#4:
			#Controlset = load("res://players/player2controls.tres")


func _process_movement():
	# Get the player's input direction (the direction they're pressing on keyboard/ control stick)
	var input_dir := get_input_vector()
	# Get the player's movement direction (relative to the camera)
	var movement_dir := get_movement_vector()
	
	# The player will be facing in the last used movement direction
	if movement_dir != Vector2.ZERO and is_action_enabled("move"):
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
	
	if !is_zero_approx(input_dir.x) and is_action_enabled("move"):
		velocity.x += acceleration_vector.x
		if limit_speed:
			velocity.x = clamp(velocity.x, -SPEED, SPEED)
	elif deceleration_enabled:
		velocity.x = move_toward(velocity.x, 0, deceleration_current)
	
	if !is_zero_approx(input_dir.y) and is_action_enabled("move"):
		velocity.z += acceleration_vector.y
		if limit_speed:
			velocity.z = clamp(velocity.z, -SPEED, SPEED)
	elif deceleration_enabled:
		velocity.z = move_toward(velocity.z, 0, deceleration_current)


func _process_actions():
	if is_action_enabled("jump"):
		_check_for_jump()
	if is_action_enabled("dash"):
		_check_for_dash()
	if is_action_enabled("air_dash"):
		_check_for_air_dash()
	if is_action_enabled("attack"):
		_check_for_attacks()


## The following functions check for an input, and then goes to a certain state
## They return true if the desired input was pressed
## They can be overridden by modders to change how actions are detected

func _check_for_jump() -> bool:
	if input("jump", "just_pressed"):
		state_machine.change_state("JumpSquat")
		return true
	return false


func _check_for_dash() -> bool:
	if input("dash", "just_pressed"):
		if state_machine.active_state.name == "Heavy":
			if state_machine.active_state.move_hit:
				state_machine.change_state("HomingDash")
				return true
		state_machine.change_state("Dash")
		return true
	return false


func _check_for_air_dash() -> bool:
	if input("jump", "just_pressed") and !is_on_floor() and air_dashes_used < MAX_AIR_DASHES:
		state_machine.change_state("AirDash")
		return true
	return false


func _check_for_attacks() -> bool:
	if _check_for_dash_attack():
		return true
	if is_on_floor():        
		if _check_for_upper():
			return true
		if _check_for_heavy():
			return true
		if _check_for_jab_combo():
			return true
		if _check_for_ground_special():
			return true
	else:
		if _check_for_aim_attack():
			return true
		if _check_for_air_attack():
			return true
		if _check_for_air_special():
			return true
	return false


# Modders can override this function to change the combo route
# Not the most user-friendly method, but it works for now until I found an easier way to make customizable jab combos
func _check_for_jab_combo() -> bool:
	if input("attack", "just_pressed"):
		# Cancelling from other jabs
		if state_machine.active_state.name == "Jab2": 
			state_machine.change_state("Jab3")
			return true
		if state_machine.active_state.name == "Jab1":
			state_machine.change_state("Jab2")
			return true
		# You cannot cancel into Jab1 from another attack
		if state_machine.active_state is not BaseAttack:
			state_machine.change_state("Jab1")
			return true
	return false


# Get the last direction pressed for heavy attack
# If none of them were pressed within the heavy input window, return empty string
func _get_last_pressed_heavy_input() -> String:
	var most_recent: String = ""
	var highest_value: int = -1
	for direction in heavy_direction_inputs:
		if heavy_direction_inputs[direction] > highest_value:
			most_recent = direction
	return most_recent


func _get_last_pressed_upper_input() -> String:
	var most_recent: String = ""
	var highest_value: int = -1
	for direction in upper_direction_inputs:
		if upper_direction_inputs[direction] > highest_value:
			most_recent = direction
	return most_recent


func _check_for_heavy() -> bool:
	if input("attack", "just_pressed"):
		# Cancel jab into heavy
		if state_machine.active_state.name == "Jab3":
			state_machine.change_state("Heavy")
			return true
		
		if state_machine.active_state.name in ["Jab1", "Jab2"] or state_machine.active_state is not BaseAttack:
			# Use a directional input if not cancelled from Jab3
			# If there was no recent heavy input, don't go into heavy state
			if _get_last_pressed_heavy_input() == "":
				return false
			state_machine.change_state("Heavy")
			return true
	return false


func _check_for_upper() -> bool:
	if input("attack", "just_pressed") and state_machine.active_state is not BaseAttack:
		if _get_last_pressed_upper_input():
			var vec = direction_string_to_vector2(_get_last_pressed_upper_input())
			if vec.x == -facing_direction_2d:
				state_machine.change_state("Upper", {attack_direction = Vector2(facing_direction_2d, 0)})
				return true
	return false


func _check_for_dash_attack() -> bool:
	if input("attack", "just_pressed") and state_machine.active_state.name == "Dash":
		state_machine.change_state("DashAttack")
		return true
	return false


func _check_for_air_attack() -> bool:
	if input("attack", "just_pressed") and !state_machine.active_state is BaseAttack:
		state_machine.change_state("AirAttack")
		return true
	return false


func _check_for_aim_attack() -> bool:
	if input("attack", "just_pressed") and state_machine.active_state.name == "HomingDash":
		state_machine.change_state("AimAttack")
		return true
	return false



func _check_for_ground_special():
	if input("skill", "just_pressed") and !state_machine.active_state is BaseAttack:
		state_machine.change_state("GrndShot")
		return true
	return false


func _check_for_air_special():
	if input("skill", "just_pressed") and !state_machine.active_state is BaseAttack:
		state_machine.change_state("AirPow")
		return true
	return false

func direction_string_to_vector2(direction_string: String) -> Vector2:
	var vec: Vector2
	if direction_string == "left":
		vec = Vector2.LEFT
	if direction_string == "right":
		vec = Vector2.RIGHT
	if direction_string == "up":
		vec =  Vector2.UP
	if direction_string == "down":
		vec = Vector2.DOWN
	return vec.rotated(camera.rotation.y)
	assert(false, "Invalid direction")
	return Vector2.ZERO


## Updates the 2d direction to match the 3D direction
## This must be called manually, because we only want to update this in specific situations, like attacking or turning around
func update_facing_direction_2d():
	# Set the direction for the hitbox and attacks
	if !is_zero_approx(facing_direction.x):
		facing_direction_2d = sign(facing_direction.x)


## Force the player to face a specific direction
func set_facing_direction_2d(direction: int):
	# Set facing direction relative to the camera
	var vec: Vector2 = Vector2(direction, 0).rotated(-camera.rotation.y)
	facing_direction_2d = sign(vec.x)


# Makes the player face the opposite direction
func flip_facing_direction_2d():
	facing_direction_2d = -facing_direction_2d


## Check whether the player should turn to face the correct direction
## Used in "Idle" and "Move" states to change to the "Turn" state
func is_turning() -> bool:
	return sign(get_movement_vector().x) != facing_direction_2d and !is_zero_approx(get_movement_vector().x)


func set_action_enabled(action: String, enabled: bool):
	assert(VALID_ACTIONS.has(action), "Invalid action: " + action)
	
	if enabled and !actions_enabled.has(action):
		actions_enabled.append(action)
	if !enabled:
		while (actions_enabled.has(action)):
			actions_enabled.erase(action)


func set_actions_enabled(actions: Array[String], enabled:bool):
	for action in actions:
		set_action_enabled(action, enabled)


func disable_all_actions():
	for action in VALID_ACTIONS:
		set_action_enabled(action, false)


func is_action_enabled(action: String):
	return actions_enabled.has(action)


## Input helper function to get input for the current player
## In the future this will also retrieve inputs received over the network (for online play)
func input(action: StringName, type: String = "pressed") -> bool:
	# Gets the correct action based on the player number (ex: attack1, attack2, attack3, etc.)
	var player_action = action + str(player_id)
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


## Movement vector is the input but rotated relative to the camera
## This allows the player to move in the correct direction no matter how the camera is rotated
func get_movement_vector() -> Vector2:
	return get_input_vector().rotated(camera.rotation.y).normalized()



func spawn_scene(spawnable_name: String, scene_path: String, pos: Vector3 = global_position, parent: Node = get_parent(), data: Dictionary = {}) -> Node:
	# Scenes are loaded every time since preloading them causes issues when two of the same projectile are spawned by different players
	# Maybe we can store it in a cache so it doesn't need to be loaded from disk every time?
	var scene: PackedScene = load(scene_path).duplicate()
	var node = scene.instantiate()
	node.global_position = pos
	if parent == null: # Allows user to skip defining a parent and use a default
		parent = get_parent()
	if node is BaseSpawnable:
		node.summoner = self
	parent.add_child(node)
	if node is BaseSpawnable:
		node._spawn(data)
	return node


func _on_hurtbox_hurt(hit_data: HitData, hitbox: Hitbox) -> void:
	current_hp = max(current_hp - hit_data.damage, 0) # Stop HP from going below zero
	state_machine.change_state("Hurt", {hit_data = hit_data})


func _on_hitbox_hit(hit_data: HitData, hurtbox: Hurtbox) -> void:
	if state_machine.active_state.has_method("_on_hitbox_hit"):
		state_machine.active_state._on_hitbox_hit(hit_data, hurtbox)
	if hurtbox.root is BattleCharacter:
		last_hit_player = hurtbox.root
