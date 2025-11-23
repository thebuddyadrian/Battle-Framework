extends TextureProgressBar

# The 3D character whose health this bar represents
@export var character: Node3D
# Camera to calculate screen-space position
var camera: Camera3D

func _ready():
	# Get the active camera
	camera = get_viewport().get_camera_3d()
	
	# Set the initial value to a placeholder (e.g., full health)
	max_value = character.max_hp

func _process(delta):
	value = character.current_hp
	
	
	match(character.player_id):
		1:
			position.x = 21
			position.y = 4
			scale.x = 1
		2:
			position.x = 220
			position.y = 4
			scale.x =-1 
		3:
			position.x = 21
			position.y = 150
			scale.x = 1
		4:
			position.x = 220
			position.y = 150
			scale.x = - 1
