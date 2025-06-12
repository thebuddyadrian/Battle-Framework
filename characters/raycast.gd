extends RayCast3D

@onready var Shadow = $Shadow
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_colliding():
		Shadow.global_position.y = get_collision_point().y
		Shadow.visible = true
	else:
		Shadow.visible = false
		#print_debug(get_collision_point())
