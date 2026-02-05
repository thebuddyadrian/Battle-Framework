extends CharacterBody3D
class_name BattleCharacter

@export var character_info: CharacterInfo
@export var IS_CLIENTSIDE = false

# Character stats, will be set from character_info resource
var max_hp: float
var move_speed: float 
var jump_velocity: float 
var gravity: float
var fall_speed: float
var acceleration: float
var deceleration: float
var air_acceleration: float
var air_deceleration: float
var max_air_actions: float
var max_air_skills: float

## How many frames the player has to press the attack button after inputting a direction to do a heavy/upper attack
var HEAVY_DIRECTION_INPUT_WINDOW: int = 8
var UPPER_DIRECTION_INPUT_WINDOW: int = 4
var taps = 0
var taptime = 0
var player_id: int = 1
var team_id: int = 1 # For team battles
var char_name: String = ""
var current_hp: int = 0
var current_stocks: int = 0
## The last used nonzero move_direction, used for dashing, air dashing, and four directional attacks
## This is set automatically during movement
var facing_direction: Vector2 = Vector2.RIGHT
## The direction for 2-Directional attacks and for the sprite
## This is NOT set automatically, and must be updated manually by calling "update_facing_direction_2d()" and other similar functions
var facing_direction_2d: int = 1
var deceleration_enabled = true
var limit_speed = true # During normal movement move_speed is limited, turn this off for stuff like dashing
var air_actions_used = 0
## Used to temporarily make acceleration faster or slower
var acceleration_scale: float = 1
var deceleration_scale: float = 1
var max_speed_scale: float = 1
var gravity_scale: float = 1
var actions_enabled: Array[String]
## A dictionary of directions that were recently pressed to input a heavy attack
var heavy_direction_inputs: Dictionary = {}
## Same but for upper
var upper_direction_inputs: Dictionary = {}
var most_recent_direction_input: String = "right"
# A list of actions, to make sure programmers don't acidentally enable non-existent actions in set_action_enabled
var VALID_ACTIONS = ["move", "jump", "dash", "air_action", "attack", "skill", "guard", "heal"]
# Keep track of the last player you hit
var last_hit_player: BattleCharacter
# Keep track of the last player who hit you
var last_player_hit_by: BattleCharacter
#This is crucial for allowing the player to move relative to the camera.
var camera: Node3D
# If active, player will not do any processing in _physics_process
var freeze_frames: int = 0
const MAX_WALL_BOUNCES = 2
var wall_bounces = 0
# If > 0, the player will have limited invincibility (check Hitbox.gd "check_if_hit" function)
var invincibility_frames = 0
# To stop the player from spamming air skill
var air_skills_used: int = 0

@onready var Sprite = $PlayerSprite
@onready var effects = $PlayerSprite/Effects
@onready var animplayer: AnimationPlayer = $PlayerSprite/AnimationPlayer
@onready var state_machine = $StateMachine
@onready var sfx := $SFX
@onready var flipped_components = $FlippedComponents


@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox

# Emitted when the player runs out of lives, see "respawn.gd"
signal kod 



func _ready() -> void:
	state_machine.initialize()
	Sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	effects.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	for child in flipped_components.get_children():
		if child is Sprite3D:
			child.billboard = BaseMaterial3D.BILLBOARD_ENABLED

	if player_id == 1:
		IS_CLIENTSIDE = true
	if IS_CLIENTSIDE == true:
		Globals.CLIENTSIDE_PLAYER = self
	team_id = player_id
	_load_stats()
	current_hp = max_hp
	# TO-DO there should be 
	current_stocks = 3


func _process(delta: float) -> void:
	# When running in editor, load stats periodically so stat changes show in realtime
	if !OS.has_feature("standalone") and Engine.get_process_frames() % 4 == 0:
		_load_stats()


func _load_stats():
	assert(character_info != null, "This character doesn't have a CharacterInfo resource! Make sure to set one in the inspector.")
	max_hp = float(character_info.max_hp)
	move_speed = float(character_info.move_speed) / 1000.0
	jump_velocity = float(character_info.jump_velocity) / 1000.0
	gravity = float(character_info.gravity) / 1000.0
	fall_speed = float(character_info.fall_speed) / 1000.0
	acceleration = float(character_info.acceleration) / 1000.0
	deceleration = float(character_info.deceleration) / 1000.0
	air_acceleration = float(character_info.air_acceleration) / 1000.0 
	air_deceleration = float(character_info.air_deceleration) / 1000.0
	max_air_actions = float(character_info.max_air_actions)
	max_air_skills = float(character_info.max_air_skills)


func _physics_process(delta: float) -> void:
	# Call _step_frozen even in freeze frames
	if state_machine.active_state.has_method("_step_frozen"):
		state_machine.active_state.call("_step_frozen")
	
	if freeze_frames > 0:
		_process_actions()
		freeze_frames = max(freeze_frames - 1, 0)
		return
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
	
	# Test Hud
	$TestLabel.text = str(wall_bounces)
	
	if taptime > 0:
		taptime -= 1
	else:
		taps = 0
	
	if input("guard", "just_pressed"):
		taps += 1
		print_debug(taps)
		
		match taps:
			1:
				taptime = 20
			2:
				if camera.rotation_degrees.y == 0:
					var rottween = create_tween()
					rottween.set_trans(Tween.TRANS_CUBIC)
					rottween.set_ease(Tween.EASE_OUT)
					rottween.tween_property(camera,"rotation_degrees:y",180,.5)
				if camera.rotation_degrees.y == 180:
					var rottween = create_tween()
					rottween.set_trans(Tween.TRANS_CUBIC)
					rottween.set_ease(Tween.EASE_OUT)
					rottween.tween_property(camera,"rotation_degrees:y",0,.5)
				taptime = 0
				taps = 0
	
	# Add the gravity.
	if velocity.y >  -fall_speed:
		velocity.y -= gravity * gravity_scale
	
	# Count down invincibility frames
	invincibility_frames = max(invincibility_frames - 1, 0)
	if invincibility_frames:
		Sprite.modulate.a = 0.5
	else:
		Sprite.modulate.a = 1
	
	_process_actions()
	_process_movement()
	move_and_slide()
	state_machine.advance()
	animplayer.advance(delta)

	Sprite.flipped = facing_direction_2d <= 0
	Sprite.scale.x = 1 if facing_direction_2d <= 0  else 1
	flipped_components.scale.x = -1 if facing_direction_2d <= 0  else 1

	## Flip sprites and other nodes
	#if camera.rotation_degrees.y >= 170:
		#Sprite.flip_h = facing_direction_2d >= 0
		#Sprite.scale.x = -1 if facing_direction_2d >= 0  else 1
		#
	#else:
		#Sprite.flip_h = facing_direction_2d < 0
		#Sprite.scale.x = -1 if facing_direction_2d >= 0  else 1
		#flipped_components.scale.x = -1 if facing_direction_2d >= 0  else 1
	#
	effects.flip_h = Sprite.flip_h
	for child in flipped_components.get_children():
		if child is Sprite3D:
			child.flip_h = Sprite.flip_h

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
		acceleration_vector = movement_dir * acceleration * acceleration_scale
	else:
		acceleration_vector = movement_dir * air_acceleration * acceleration_scale
	
	var deceleration_current = deceleration if is_on_floor() else air_deceleration
	deceleration_current *= deceleration_scale

	var speed_current = move_speed * max_speed_scale
	
	if !is_zero_approx(input_dir.x) and is_action_enabled("move"):
		velocity.x += acceleration_vector.x
		if limit_speed:
			velocity.x = clamp(velocity.x, -speed_current, speed_current)
	elif deceleration_enabled:
		velocity.x = move_toward(velocity.x, 0, deceleration_current)
	
	if !is_zero_approx(input_dir.y) and is_action_enabled("move"):
		velocity.z += acceleration_vector.y
		if limit_speed:
			velocity.z = clamp(velocity.z, -speed_current, speed_current)
	elif deceleration_enabled:
		velocity.z = move_toward(velocity.z, 0, deceleration_current)

# Check for various actions
# First, make sure the action is enabled, then check for input and other conditions using their designated function
func _process_actions():
	if is_action_enabled("jump"):
		_check_for_jump()
	if is_action_enabled("dash"):
		_check_for_dash()
	if is_action_enabled("air_action"):
		_check_for_air_action()
	if is_action_enabled("attack"):
		_check_for_attacks()
	if is_action_enabled("guard"):
		_check_for_guard()


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
		# If following up from a heavy attack, do a homing dash instead
		if state_machine.active_state.name == "Heavy":
			if state_machine.active_state.move_hit:
				state_machine.change_state("HomingDash", {"opponent": last_hit_player})
				return true
		state_machine.change_state("Dash")
		return true
	return false


func _check_for_air_action() -> bool:
	if input("jump", "just_pressed") and !is_on_floor() and air_actions_used < max_air_actions:
		state_machine.change_state("AirAction")
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
	if input("attack", "just_pressed") or (state_machine.active_state is BaseAttack and state_machine.active_state._attack_cancel_buffered):
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


func _check_for_guard() -> bool:
	if input("guard", "just_pressed"):
		state_machine.change_state("Guard")
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
	if input("attack", "just_pressed") or (state_machine.active_state is BaseAttack and state_machine.active_state._attack_cancel_buffered):
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
	if input("upper", "just_pressed") and state_machine.active_state is not BaseAttack:
		state_machine.change_state("Upper", {attack_direction = Vector2(facing_direction_2d, 0)})
		return true
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
	if input("skill", "just_pressed") and !state_machine.active_state is BaseAttack and air_skills_used < max_air_skills:
		# Count the amount of air skills used in the air. Will be reset in idle.gd
		air_skills_used += 1
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
	facing_direction.x = facing_direction_2d


## Makes the player face the opposite direction
func flip_facing_direction_2d():
	facing_direction_2d = -facing_direction_2d
	facing_direction.x = facing_direction_2d


func match_facing_direction_to_movement():
	facing_direction = get_movement_vector()


## Check whether the player should turn to face the correct direction
## Used in "Idle" and "Move" states to change to the "Turn" state
func is_turning() -> bool:
	return sign(get_movement_vector().x) != facing_direction_2d and !is_zero_approx(get_movement_vector().x)


## Allows/Disallows the player to perform a specific action. Check "_process_actions" to understand how it works better.
## Usually called at the start of a state script to define what actions can be done during that state
func set_action_enabled(action: String, enabled: bool):
	assert(VALID_ACTIONS.has(action), "Invalid action: " + action)
	
	if enabled and !actions_enabled.has(action):
		actions_enabled.append(action)
	if !enabled:
		while (actions_enabled.has(action)):
			actions_enabled.erase(action)


## Same as "set_action_enabled" but br
func set_actions_enabled(actions: Array[String], enabled:bool):
	for action in actions:
		set_action_enabled(action, enabled)


## Disables all the actions defined in the "VALID_ACTIONS" constant
func disable_all_actions():
	for action in VALID_ACTIONS:
		set_action_enabled(action, false)


## Checks if an action is enabled
func is_action_enabled(action: String):
	return actions_enabled.has(action)


## Input helper function to get input for the current player
## In the future this will also retrieve inputs received over the network (for online play)
func input(action: StringName, type: String = "pressed") -> bool:
	# Gets the correct action based on the player number (ex: attack1, attack2, attack3, etc.)
	var player_action = action + str(player_id)
	if !InputMap.has_action(player_action):
		push_error("Action %s doesn't exist" % player_action)
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


## Spawns a scene given the filepath, useful for projectiles, traps, and other spawable objects
func spawn_scene(spawnable_name: String, scene_path: String, pos: Vector3 = global_position, parent: Node = get_parent(), data: Dictionary = {}) -> Node:
	# Scenes are loaded every time since preloading them causes issues when two of the same projectile are spawned by different players
	# Maybe we can store it in a cache so it doesn't need to be loaded from disk every time?
	var scene: PackedScene = load(scene_path).duplicate()
	var node = scene.instantiate()
	node.global_position = pos
	data["dir"] = facing_direction_2d
	if parent == null: # Allows user to skip defining a parent and use a default
		parent = get_parent()
	if node is BaseSpawnable:
		node.summoner = self
	parent.add_child(node)
	if node is BaseSpawnable:
		node._spawn(data)
	elif node.has_method("_on_spawn"):
		node._on_spawn(data)
	return node


## Plays a sound found in the assets/audio/sfx/battle folder
func play_sound_effect(sound_name: String):
	var stream = load("assets/audio/sfx/battle/" + sound_name + ".wav")
	SoundEffectPlayer.play_sound_effect(sound_name, stream, "SFX", global_position)


## Plays a voice clip found in the assets/audio/voice/battle folder
func play_voice_clip(voice_clip_name: String):
	var stream = load("assets/audio/voice/battle/" + voice_clip_name + ".wav")
	SoundEffectPlayer.play_sound_effect(voice_clip_name, stream, "Voice", global_position)


# Gets the position of the ground beneath the player. Used for certain spawnables like Tails AirPow
# Starts at the player's position by default, but can be offset to check in front of the player for example
func get_ground_position(offset: Vector3 = Vector3.ZERO):
	# Get the space state
	var space_state := get_world_3d().direct_space_state
	# Apply offset
	var ray_cast_position: Vector3 = global_position + offset
	# Setup the raycast
	var start: Vector3 = ray_cast_position
	# Ray goes downwards
	var end: Vector3 = ray_cast_position + Vector3.DOWN * 10

	var query := PhysicsRayQueryParameters3D.create(start, end)
	var result := space_state.intersect_ray(query)

	# Return the position the ray collided with
	if result:
		return result.position
	# Return the bottom of the raycast as a fallback
	return end


## When the player gets hit
func _on_hurtbox_hurt(hit_data: HitData, attacker_hitbox: Hitbox) -> void:
	current_hp = max(current_hp - hit_data.damage, 0) # Stop HP from going below zero
	state_machine.change_state("Hurt", {hit_data = hit_data})
	freeze_frames = hit_data.get_hit_freeze()
	animplayer.advance(0) # Play the first frame of hurt animation
	if attacker_hitbox.root is BattleCharacter:
		last_player_hit_by = attacker_hitbox.root


## When the player succesfully lands a hit
func _on_hitbox_hit(hit_data: HitData, opponent_hurtbox: Hurtbox) -> void:
	if state_machine.active_state.has_method("_on_hitbox_hit"):
		state_machine.active_state._on_hitbox_hit(hit_data, hurtbox)
	# TO-DO - Instead of hardcoding a sound effect it should depend on the defined hit sound
	play_sound_effect("hit_light")
	freeze_frames = hit_data.get_hit_freeze()
	if opponent_hurtbox.root is BattleCharacter:
		last_hit_player = opponent_hurtbox.root


## When the player hits a guarding opponent, go to the "Blocked" state to stagger back
func _on_hitbox_blocked(hit_data: HitData, hurtbox: Hurtbox) -> void:
	state_machine.change_state("Blocked", {hit_data = hit_data})
	play_sound_effect("blocked")
