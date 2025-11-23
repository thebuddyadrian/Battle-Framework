extends Resource
class_name HitData

# A resource that stores data a player will need when hitting opponents or getting hit by an attack

enum KNOCKBACK_TYPE {WEAK, LAUNCH, UP, DOWN, KNOCKDOWN}

@export var damage: float 
@export var knockback_direction: Vector2 = Vector2(0, 0) # The direction the player will be hit, in regards to the XZ plane
@export var knockback_power: float = 20 # How far the player gets hit
@export var knockback_angle: float = 30 # The angle the player will get hit upwards, in regards to the plane with its width defined by the knockback_direction and the Y axis
@export var knockback_type: KNOCKBACK_TYPE = KNOCKBACK_TYPE.WEAK
@export var unblockable: bool = false
@export var hit_freeze_override: int = -1
@export var hit_stun: int = 30


func calculate_knockback_velocity() -> Vector3:
	var vec: Vector3
	var angle_rad = deg_to_rad(knockback_angle)
	vec.y = knockback_power * sin(angle_rad)
	vec.x = knockback_power * cos(angle_rad) * knockback_direction.x 
	vec.z = knockback_power * cos(angle_rad) * knockback_direction.y
	return vec


func get_hit_freeze() -> int:
	if hit_freeze_override > -1:
		return hit_freeze_override
	return ceil(damage/4)
