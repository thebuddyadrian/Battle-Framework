extends Resource
class_name SpawnableInfo

@export var sprite_path: String = "assets/Textures/Spawnables/BaseSpawnable/sprite.png"
@export var sprite_scale: float = 1.0
@export var has_animation: bool = false

@export var has_hitbox: bool = false
@export var has_hurtbox: bool = true

@export var hit_start_millis: int = 0
@export var hurt_start_millis: int = 250

@export var lifetime_millis: int = -1
