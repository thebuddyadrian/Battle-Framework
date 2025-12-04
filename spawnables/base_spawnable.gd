extends CharacterBody3D
class_name BaseSpawnable

var despawn_timer: Timer = Timer.new()
var hit_start_timer: Timer = Timer.new()
var hurt_start_timer: Timer = Timer.new()
var exist_time: float = 0.0
var direction: Vector2 = Vector2.RIGHT
var freeze_frames: int = 0

var summoner: Node = null

@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var sprite: AnimatedSprite3D = $Sprite

@export var spawnable_info: SpawnableInfo

# Do Not Override:tm:
func _init():
	self.despawn_timer.connect("timeout", self._on_despawn_timeout)
	self.hurt_start_timer.connect("timeout", self._on_hurt_start_timeout)
	self.hit_start_timer.connect("timeout", self._on_hit_start_timeout)
	self._on_init()

# Do not Override:tm:
func _spawn(data := {}):
	if data.has("direction"):
		direction = data["direction"]
	if data.has("velocity"):
		velocity = data["velocity"]
	hitbox.hit_data.knockback_direction = direction
	self._on_spawn(data)

# Do Not Override:tm:
func _ready():
	assert (spawnable_info, "Spawnable lacks info! Spawnable: " + self.name)
	if (self.spawnable_info.lifetime_millis > -1): 
		add_child(despawn_timer)
		self.despawn_timer.wait_time = self.spawnable_info.lifetime_millis/1000.0
		self.despawn_timer.start()
	
	hitbox.active = false
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	if self.spawnable_info.hit_start_millis > 0:
		add_child(hit_start_timer)
		self.hit_start_timer.wait_time = self.spawnable_info.hit_start_millis/1000.0
		self.hit_start_timer.one_shot = true
		self.hit_start_timer.start()
	else:
		hitbox.active = spawnable_info.has_hitbox

	
	if (self.spawnable_info.has_animation):
		var spriteTex = load(self.spawnable_info.sprite_path)
		self.sprite.sprite_frames.add_frame("default", spriteTex)
	else:
		self.sprite.sprite_frames = load(self.spawnable_info.sprite_path)
	
	
	self.hitbox.connect("hit", self._on_hit)
	self.hurtbox.connect("hurt", self._on_hurt)
	
	self.hitbox.connect("grab", self._on_grab)
	self.hurtbox.connect("grabbed", self._on_grabbed)
	
	self.hitbox.connect("clash", self._on_clash)
	self.hitbox.connect("blocked", self._on_blocked)
	
	self.hurtbox.connect("thrown", self._on_thrown)
	
	self._on_ready()

# Do Not Override:tm:
func _physics_process(delta):
	if freeze_frames > 0:
		freeze_frames -= 1
		return
	exist_time += delta
	move_and_slide()
	self._do_behavior(delta)
	

# Overridable functions.

## Runs during init. Do not access @onready vars from here.
func _on_init():
	pass

## Runs after being spawned by a player. Used to pass in data.
func _on_spawn(data: = {}):
	pass

## Runs after ready. Access @onready vars from here. Don't use preload() here.
func _on_ready():
	pass

## Runs on despawn timeout. Override if you want custom despawn behavior, otherwise don't touch this.
func _on_despawn_timeout():
	self.queue_free()

func _on_hurt_start_timeout():
	if spawnable_info.has_hurtbox:
		self.hurtbox.active = true

func _on_hit_start_timeout():
	if spawnable_info.has_hitbox:
		self.hitbox.active = true

## Runs during the physics process. Has delta time as a var. Use this instead of overriding physics process.
func _do_behavior(delta):
	pass

## Runs after a hit.
func _on_hit(hit_data: HitData, hurtbox: Hurtbox):
	# TO-DO - Instead of hardcoding a sound effect it should depend on the defined hit sound
	play_sound_effect("hit_light")
	freeze_frames = hit_data.get_hit_freeze()

## Runs after object is hit.
func _on_hurt(hit_data: HitData, hitbox: Hitbox):
	pass

## Runs when grabbed.
func _on_grabbed():
	pass

## Runs if the spawnable 'grabs'.
func _on_grab():
	pass

## Runs on clash.
func _on_clash():
	pass

## Runs after blocked.
func _on_blocked(_hit_data, _hurtbox):
	queue_free()

## Runs after being thrown.
func _on_thrown():
	pass

func reactivate_hitbox():
	hitbox.active = true
	hitbox.nodes_already_hit.clear()

## Plays a sound found in the assets/audio/sfx/battle folder
func play_sound_effect(sound_name: String):
	var stream = load("assets/audio/sfx/battle/" + sound_name + ".wav")
	SoundEffectPlayer.play_sound_effect(sound_name, stream, "SFX", global_position)
