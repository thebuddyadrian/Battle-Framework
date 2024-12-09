extends CharacterBody3D

class_name BattleCharacter


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var STOCKS = 3
@export var PLAYER = 1
@export var GRAVITY = 5
@export var JUMPFROMGROUND = false

@export var Controlset = MoonCastControlSettings.new()

@onready var Sprite = $PlayerSprite

func _anim_switch() -> void: #Put this in a separate script when you can
	if !is_on_floor():
		if JUMPFROMGROUND == true:
			$PlayerSprite/AnimationPlayer.play("Jump")
		else:
			$PlayerSprite/AnimationPlayer.play("Falling")
	else:
		JUMPFROMGROUND = false
		if velocity.x != 0 || velocity.z != 0:
			$PlayerSprite/AnimationPlayer.play("Moving")
		else:
			$PlayerSprite/AnimationPlayer.play("Idle")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity.y -= GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed(Controlset.action_jump) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		JUMPFROMGROUND = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector(Controlset.direction_left, Controlset.direction_right, Controlset.direction_up, Controlset.direction_down)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if !is_zero_approx(direction.x):
		Sprite.flip_h = direction.x < 0
		
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_anim_switch()
