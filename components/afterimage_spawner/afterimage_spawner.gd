extends Node
class_name AfterImageSpawner

@export var sprite_path: NodePath

var enabled: bool = false
var interval: int = 4 # Frames in between each afterimage spawn
var duration: int = 20 # How long each afterimage stays on screen
var tint_color: Color # What color to tint the afterimages
var opacity: float
var _afterimage_nodes: Array # Store spawned afterimages in an array
var _ticks: int = 0 # How many ticks have passed since being enabled
var _material: ShaderMaterial

var sprite: Node

func _ready():
	sprite = get_node(sprite_path)
	_material = ShaderMaterial.new()
	assert(sprite is BattleSprite3D or sprite is BattleAnimatedSprite3D)
	add_to_group("network_sync")


func _process(delta):
	if enabled:
		if _ticks % interval == 0:
			_spawn_afterimage()
		_ticks += 1
	else:
		_ticks = 0


# Create a child sprite node with the afterimage parameters
func _spawn_afterimage():
	var afterimage := BattleSprite3D.new()
	if sprite is BattleSprite3D:
		afterimage.texture = sprite.texture
	if sprite is BattleAnimatedSprite3D:
		afterimage.texture = sprite.sprite.texture
	afterimage.set_as_toplevel(true)
	afterimage.modulate.a = 0.5
	afterimage.global_transform = sprite.global_transform
	afterimage.z_index = sprite.z_index - 1
	afterimage.material = _material
	afterimage.material.set_shader_param("solid_color", tint_color)
	afterimage.modulate.a = opacity
	afterimage.flipped = sprite.flipped
	_afterimage_nodes.append(afterimage)

	var despawn_timer = get_tree().create_timer(duration * 0.016)
	despawn_timer.timeout.connect(_despawn_afterimage, afterimage)
	
	add_child(afterimage)


func _despawn_afterimage(afterimage: Sprite3D):
	_afterimage_nodes.erase(afterimage)
	if afterimage:
		afterimage.queue_free()


# Removes all spawned afterimages
func clear():
	for afterimage in _afterimage_nodes:
		_afterimage_nodes.erase(afterimage)
		afterimage.queue_free()


func _save_state() -> Dictionary:
	return {
		_enabled = enabled,
		_interval = interval,
		_duration = duration,
		_tint_color = tint_color,
		_opacity = opacity,
	}


func _load_state(state: Dictionary):
	if enabled and !state["_enabled"]:
		clear()
	enabled = state["_enabled"]
	interval = state["_interval"]
	duration = state["_duration"]
	tint_color = state["_tint_color"]
	opacity = state["_opacity"]
