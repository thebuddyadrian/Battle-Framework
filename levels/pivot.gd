extends Node3D

@onready var Anim = $AnimationPlayer

var taps = 0
var taptime = 0
var follow_player = false
var player_to_follow: BattleCharacter : set = set_player_to_follow

var _offset_from_player: Vector3


func _ready() -> void:
	rotation.y = 0
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var rot = snappedi(rotation.y, 1.0)
	
	if taptime > 0:
		taptime -= 1
	else:
		taps = 0
	if Input.is_action_just_pressed("Flipcam"):
		taps += 1
		
		match taps:
			1:
				taptime = 20
			2:
				match rot:
					0:
						Anim.play("Flip1")
					3:
						Anim.play("Flip2")
				taptime = 0
				taps = 0
	
	if follow_player and player_to_follow:
		global_position = player_to_follow.global_position


func set_player_to_follow(player: BattleCharacter):
	player_to_follow = player
	_offset_from_player = global_position - player_to_follow.global_position
