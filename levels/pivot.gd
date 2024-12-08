extends Node3D

@onready var Anim = $AnimationPlayer

func _ready() -> void:
	rotation.y = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rot = snappedi(rotation.y, 1.0)
	if Input.is_action_just_pressed("Flipcam"):
		print_debug(rot)
		match rot:
			0:
				Anim.play("Flip1")
			3:
				Anim.play("Flip2")
		
	pass
