extends Node3D
@export var vert = 1
@export var hori = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation.x = randi_range(0, 5)
	rotation.y = randi_range(0, 5)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotation.y += 0.1 * vert * delta
	rotation.x += 0.1 * hori * delta
	pass
