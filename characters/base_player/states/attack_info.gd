extends Resource
class_name AttackInfo

## The animation used for the attack
@export var animation: String = ""
## Air animation, if left blank will use animation
@export var air_animation: String = ""
@export var animation_down: String = ""
@export var animation_up: String = ""
## If true, the air animation will be used in the air, otherwise only animation will be used
@export var change_anim_in_air: bool = false

@export var startup_frames: int = 2
@export var active_frames: int = 2
@export var recovery_frames: int = 10
# Split up the animation into the startup, active, and recovery sections
@export var attack_sound: String = "punch_light"
@export var damage: int = 15
@export var knockback_power: int = 25
@export var knockback_angle: int = 0
@export var knockback_type: HitData.KNOCKBACK_TYPE = HitData.KNOCKBACK_TYPE.WEAK
@export var hit_stun: int = 30
@export var hit_sound: String = "punch_light"
@export var can_charge: bool = false
@export var max_charge: int = 30
@export var max_hold: int = 30
@export var knockback_charge_scale: int = 180
@export var damage_charge_scale: int = 150
@export var knockback_scaling_charge_scale: int = 180


## Can be used to disable the hitbox for projectile attacks
@export var use_hitbox: bool = true
## Go into land state when on the ground, useful for air attacks
@export var land_on_touched_ground: bool = false
## Go into air state when not on the ground, useful for ground only attacks
@export var stop_on_left_ground: bool = false
## How many frames the player will be in the landing state after touching ground
@export var landing_lag: int = 6
## Lets the player cancel this move into a Homing Dash on hit, used for heavy attacks
@export var dash_cancel_on_hit: bool = false
## How many frames until the player can cancel into the homing dash
@export var dash_cancel_frames: int = 24
