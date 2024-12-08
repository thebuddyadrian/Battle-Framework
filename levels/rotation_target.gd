extends Node3D

@onready var Anim = $AnimationPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	if Input.is_action_pressed("Flipcam"):
		rotation.y += 5
	pass
