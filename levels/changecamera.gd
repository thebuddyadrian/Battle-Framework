extends Area3D

@export var phantcam: PhantomCamera3D
@export var path1 : Path3D
@export var path2 : Path3D

var Camswitch = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match(Camswitch):
		true:
			phantcam.follow_path = path2
		false:
			phantcam.follow_path = path1
	pass


func _on_body_entered(body:Node3D) -> void:
	Camswitch = !Camswitch
	pass # Replace with function body.
