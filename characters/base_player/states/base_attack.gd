extends BaseState
class_name BaseAttack

## TWO_DIR: Attacks that can only knock left and right (ex: jab combo)
## FOUR_DIR: Attacks that can launch in four directions (ex: Heavy)
enum DIR_TYPE {TWO_DIR, FOUR_DIR}

const DEFAULT_STARTUP_FRAMES: int = 2
const DEFAULT_ACTIVE_FRAMES: int = 2
const DEFAULT_RECOVERY_FRAMES: int = 10

@export var attack_info: AttackInfo

# The state the move goes to after the last phase
var next_state: String = "Idle"
# The data passed to the next state
var next_state_data: Dictionary = {}
## The animation used for the attack
var animation: String = ""
## Air animation, if left blank will use animation
var air_animation: String = ""
## If true, the air animation will be used in the air, otherwise only animation will be used
var change_anim_in_air: bool = false
## Down and up animations for four-directional moves (specials)
var animation_down: String
var animation_up: String
var animation_down_start_frame: int = 0
var animation_up_start_frame: int = 0
var animation_flip_offset_frame_start: int = 0
var _flipped_frame_offset: int  = 0

## Not finished yet
var charge_time: int = 0
var current_phase_index: int = -1
var move_contact: int = 0
var move_hit: int = 0
var move_blocked: int = 0
var num_hits: int = 0
var num_contacts: int = 0
var num_blocked: int = 0

## Whole Move Config

## Can be used to disable the hitbox for projectile attacks
var use_hitbox: bool = true
## Go into land state when on the ground, useful for air attacks
var land_on_touched_ground: bool = false
## Go into land state when on the ground, useful for air attacks
var stop_on_left_ground: bool = false
## How many frames the player will be in the landing state after touching ground
var landing_lag: int = 6
## Lets the player cancel this move into a Homing Dash on hit, used for heavy attacks
var dash_cancel_on_hit: bool = false
## How many frames until the player can cancel into the homing dash
var dash_cancel_frames: int = 24
## Can be set to false to disable the animation system
var play_animation: bool = true
## Can be set to false to manually set the section start and end for each phase
var use_anim_markers: bool = true
## Can be set to false to disable the animation sections and just play the whole animation
var use_sections: bool = true
var direction_type: DIR_TYPE = DIR_TYPE.TWO_DIR
## Direction for the attack, which is where the opponent will be knocked/ the projectile will be shot
var attack_direction := Vector2.RIGHT

# Default attack phases generated from AttackInfo
var charge_phase: AttackPhase
var startup_phase: AttackPhase
var active_phase: AttackPhase
var recovery_phase: AttackPhase

var _use_air_animation: bool = false
# When the player presses the dash button, it will be buffered until the move is ready to cancel
var _dash_cancel_buffered: bool = false
# When the player presses the attack button, it will be buffered until the move is ready to cancel
var _attack_cancel_buffered: bool = false
## Array of phases created for the attack
var _phases := []
var _phases_dict := {}
## Used to count down to the next phase
var _phase_timer: int = 0
# Keeps tracks of variables for looping animations
var _current_phase_loop: bool = false
var _current_animation: String
var _current_section_start: float
var _current_section_end: float


class PhaseSetArray:
	var phase_sets := []
	
	func get_phase_set(idx: int) -> PhaseSet:
		return phase_sets[idx] as PhaseSet
	

# A class containing the standard phases used by most attacks
class PhaseSet:
	var charge: AttackPhase
	var startup: AttackPhase
	var active: AttackPhase
	var recovery: AttackPhase
	
	func _init():
		charge = AttackPhase.new("charge")
		charge.phase_type = AttackPhase.PHASE_TYPE.CHARGE
		startup = AttackPhase.new("startup")
		startup.frames = DEFAULT_STARTUP_FRAMES
		active = AttackPhase.new("active")
		active.hitbox_active = true
		active.frames = DEFAULT_ACTIVE_FRAMES
		recovery = AttackPhase.new("recovery")
		recovery.frames = DEFAULT_RECOVERY_FRAMES


## Class for defining a window/phase of the attack
class AttackPhase:
	## NORMAL: Automatically switch to next phase when phase timer ends
	## CHARGE: Switch to next phase when attack button released, then set charge_time
	## JAB: If the attack button is pressed during this frame, go to next phase
	## RAPID: If the attack button is not pressed for a few frames, switch to next phase
	## MANUAL: Attack will not go to next phase automatically
	enum PHASE_TYPE {NORMAL, CHARGE, JAB, RAPID, MANUAL}
	var phase_type: int = PHASE_TYPE.NORMAL
	
	## The name of the phase should match the name of the marker set in the AnimationPlayer
	var phase_name: String = ""
	
	## How long the phase lasts until going to the next one 
	var frames: int = 0
	
	## If you want this phase to have a different animation from the one set for the whole move
	var anim_override: String = ""
	var air_anim_override: String = ""
	
	## Can be used to set a different marker than the phase name 
	var anim_marker: String = ""
	
	## Can be used to manually set the section of the animation to use
	var anim_frame_start: int = 0
	var anim_frames: int = 0 : get = get_frames, set = set_frames
	var anim_frame_end: int = 0
	
	# Ignore, carried over from my other project
	var add_whiff_lag: bool = false
	
	## If true, the move will end right after this phase
	var end_phase: bool = false
	
	## Sounds
	var sound_effect: String = ""
	var sound_offset: int = 0
	var voice_clip: String = ""
	var voice_offset: int = 0
	
	## Go into land state when on the ground, useful for air attacks
	var land_on_touched_ground: bool = false
	var landing_frames: int = 6
	var hitbox_active: bool = false
	
	# Charge
	var max_charge: int = 30
	var max_hold: int = 30
	var use_charge_effect: bool = false
	
	# Jab
	var jab_transition_offset: int = 4
	var jab_transition_offset_whiff: int = 6
	
	# Multi Hit
	var multi_hit_frequency: int = 0
	
	func to_dict() -> Dictionary:
		var dict := {}
		for property in get_property_list():
			if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
				dict[property["name"]] = get(property["name"])
		return dict
	
	func get_frames():
		return anim_frame_end - anim_frame_start
	
	func set_frames(p_frames):
		anim_frame_end = p_frames - anim_frame_start

	func _init(p_phase_name):
		phase_name = p_phase_name
		anim_marker = p_phase_name


func _ready():
	if animation == "":
		animation = name
	if air_animation == "":
		air_animation = name + " Air"
	add_to_group("attack")


func _enter(data := {}):
	_phases.clear()
	_setup_from_resource()
	_move_setup()
	_check_for_errors()
	root.hitbox.active = false
	#root.hitbox.rects = []
	root.hitbox.hit_data = HitData.new()
	# Attack Direction can be passed in as a parameter
	if data.has("attack_direction"):
		attack_direction = data["attack_direction"]
	# Otherwise, try to infer from inputs
	else:
		if !is_zero_approx(root.get_movement_vector().x):
			attack_direction.x = round(root.get_movement_vector().x)
			attack_direction.y = 0
		elif !is_zero_approx(root.get_movement_vector().y):
			attack_direction.x = 0
			attack_direction.y = round(root.get_movement_vector().y)
		else:
			attack_direction.x = round(root.facing_direction_2d)
			attack_direction.y = 0

	root.hitbox.hit_data.knockback_direction = attack_direction
	root.hitbox.rotation.y = -attack_direction.angle()
	root.facing_direction = attack_direction
	root.update_facing_direction_2d()
	#root.hitbox.hit_data.charge_percent = 0
	num_hits = 0
	num_contacts = 0
	move_contact = 0
	move_hit = 0
	charge_time = 0
	_phase_timer = 0
	_dash_cancel_buffered = false
	_attack_cancel_buffered = false
	_flipped_frame_offset = 0
	change_phase(0)


## Generates attack phases based on the attached AttackInfo resource
func _setup_from_resource():
	if attack_info == null:
		return
	animation = attack_info.animation
	air_animation = attack_info.air_animation
	animation_up = attack_info.animation_up
	animation_down = attack_info.animation_down
	animation_down_start_frame = attack_info.animation_down_start_frame
	animation_up_start_frame = attack_info.animation_up_start_frame
	animation_flip_offset_frame_start = attack_info.animation_flip_offset_frame_start
	change_anim_in_air = attack_info.change_anim_in_air
	play_animation = attack_info.play_animation
	use_anim_markers = attack_info.use_anim_markers
	use_sections = attack_info.use_sections
	use_hitbox = attack_info.use_hitbox
	land_on_touched_ground = attack_info.land_on_touched_ground
	stop_on_left_ground = attack_info.stop_on_left_ground
	landing_lag = attack_info.landing_lag
	dash_cancel_on_hit = attack_info.dash_cancel_on_hit
	dash_cancel_frames = attack_info.dash_cancel_frames
	
	if attack_info.can_charge:
		charge_phase = AttackPhase.new("charge")
		charge_phase.phase_type = AttackPhase.PHASE_TYPE.CHARGE
		charge_phase.max_charge = attack_info.max_charge
		charge_phase.max_hold = attack_info.max_hold
		charge_phase.use_charge_effect = true
		add_phase(charge_phase)
	
	startup_phase = AttackPhase.new("startup")
	startup_phase.frames = attack_info.startup_frames
	add_phase(startup_phase)
	
	active_phase = AttackPhase.new("active")
	active_phase.frames = attack_info.active_frames
	active_phase.hitbox_active = use_hitbox
	active_phase.sound_effect = attack_info.attack_sound
	active_phase.voice_clip = attack_info.attack_voice
	add_phase(active_phase)
	
	recovery_phase = AttackPhase.new("recovery")
	recovery_phase.frames = attack_info.recovery_frames
	recovery_phase.end_phase = true
	add_phase(recovery_phase)


## Virual method called when the player should set up the attack phases using "add_new_phase" calls
func _move_setup():
	pass


## Makes sure no mistakes were made when setting up the attack
func _check_for_errors():
	# Make sure the attack has at least one phase
	if _phases.is_empty():
		assert(false, "This attack has no phases! Did you forget to attach an AttackInfo resource? If you're not using an AttackInfo resource, make sure to set up your phases manually in the _move_setup() function.")
		return

	# Make sure the attack has an end phase
	var has_end_phase = false
	for phase in _phases:
		if phase.end_phase:
			has_end_phase = true
	if !has_end_phase:
		assert(false, "This attack has no end phase! Make sure one of your attack phases has the end_phase variable set to true.")
		return
	
	# Make sure up and down start frames are set when up and down animations are used.
	if animation_down != "" and animation_down_start_frame == -1:
		assert(false)
	
	if animation_up != "" and animation_up_start_frame == -1:
		assert(false)


func _step():
	if root.is_in_group("characters"):
		if (get_current_phase().land_on_touched_ground or land_on_touched_ground) and root.is_on_floor():
			parent.change_state("Land", {landing_frames = max(get_current_phase().landing_frames, landing_lag)})
			return
		
		# Charging - WIP
		#if get_current_phase().phase_type == AttackPhase.PHASE_TYPE.CHARGE:
			#charge_time = min(charge_time + 1, 
					#get_current_phase().max_charge)
			#if charge_time >= get_current_phase().max_hold:
				#release_charge()
			#if !root.input_attack("pressed"):
				#release_charge()
		
		# Dash Cancel
		if move_hit and dash_cancel_on_hit:
			if root.input("dash", "just_pressed"):
				_dash_cancel_buffered = true
			if parent.state_time >= dash_cancel_frames and _dash_cancel_buffered:
				change_state("HomingDash", {"opponent": root.last_hit_player})
				return


		# OLD JAB CODE
		# # Jabs
		# # Cancel into next phase when attack pressed
		# if get_current_phase().phase_type == AttackPhase.PHASE_TYPE.JAB:
		# 	var transition_offset = get_current_phase().jab_transition_offset
		# 	if move_contact == 0:
		# 		transition_offset = get_current_phase().jab_transition_offset_whiff
		# 	if _phase_timer <= get_current_phase().frames - transition_offset or _phase_timer <= 2:
		# 		if root.input_attack("pressed"):
		# 			root.stop_buffer_attack("pressed")
		# 			root.stop_buffer("special", "pressed")
		# 			next_phase()
	
	# Looping animations
	# When the animation finishes, play it again
	if _current_phase_loop:
		var animation_looped = _current_animation
		if !_current_animation.ends_with("_loop"):
			animation_looped = _current_animation + "_loop"
		print("looping: %s" % _current_animation)
		print(_current_section_start)
		root.animplayer.play_section(_current_animation, _current_section_start, _current_section_end, -1, 1)
	

	# Apply sprite flip offset
	if (root.animplayer.current_animation_position*60) >= animation_flip_offset_frame_start:
		root.Sprite.flipped_frame_offset = _flipped_frame_offset
	else:
		root.Sprite.flipped_frame_offset = 0

	if _phase_timer > 0:
		_phase_timer = max(0, _phase_timer - 1)
		if _phase_timer == 0:
			if get_current_phase().end_phase:
				parent.change_state(next_state, next_state_data)
				return
			next_phase()
	
	# Jump cancel upper attacks
	if name == "Upper" and move_hit:
		root.set_action_enabled("jump", true)
	

	if parent.state_time == 2 and name == "Heavy" and root.char_name != "shadow":
		root.spawn_scene("HeavyEffect", "res://effects/heavy_effect.tscn", root.global_position, root.get_parent(), {direction = root.facing_direction_2d})


	
func _step_frozen():
	#Count up move_hit and move_contact
	if move_hit > 0:
		move_hit += 1
	
	if move_contact > 0:
		move_contact += 1
	
	# Jab Buffer
	if parent.state_time > 1 and root.input("attack", "just_pressed"):
		_attack_cancel_buffered = true

	#root.attack_trail.trail_state = {}
	#if root.is_in_group("fighter"):
		#if dash_cancel and move_hit > 0 and MatchSetup.rule_set.dash_cancels == true:
			#root.dash_cooldown = 0
			#root.set_action_enabled("dash", true)
		#if special_cancel and move_contact > 0 and MatchSetup.rule_set.special_cancels:
			#root.set_action_enabled("special", true)
		#if hitfall and move_contact > 0 and root.input("down", "pressed"):
			#root.do_fast_fall()


func _phase_changed_internal(phase_index: int, previous_phase_index: int):
	if attack_info:
		if get_current_phase() == active_phase:
			apply_hit_data()

		# Player can cancel into other attacks when recovery phase starts
		if get_current_phase() == recovery_phase:
			root.set_action_enabled("attack", true)
	

# Virtual method to run logic right when the phase is changed, including at the beginning when startup phase is entered
func _phase_changed():
	pass


#
#func _spawn_charge_effect():
	#if root.is_in_group("fighter"):
		#_charge_effect_path = get_path_to(
				#root.spawn_scene("ChargeEffect", "res://Effects/ChargeEffect/ChargeEffect.tscn",
				#root.charge_position.get_global_fixed_position(), root.get_parent()))


#func _despawn_charge_effect():
	#if root.is_in_group("fighter"):
		#if get_node_or_null(_charge_effect_path):
			#SyncManager.despawn(get_node(_charge_effect_path))
			#_charge_effect_path = ""


func _extract_trailing_int(text) -> String:
	var int_string = ""
	for i in range(text.length() - 1, -1, -1):
		var current_char = text[i]
		if current_char.is_valid_integer():
			int_string += current_char
		else:
			break

	return int_string


func _get_unique_phase_name(p_phase_name: String) -> String:
	for phase in _phases:
		if phase.phase_name == p_phase_name:
			var trailing_int_string: String = _extract_trailing_int(p_phase_name)
			var trailing_int: int = 0
			if trailing_int_string != "":
				trailing_int = int(trailing_int_string)
			p_phase_name += str(trailing_int + 1)
	return p_phase_name

func _on_hitbox_hit(hit_data: HitData, hurtbox):
	num_hits += 1
	move_hit = 1
	num_contacts += 1
	move_contact = 1


func _exit(next_state):
	root.hitbox.active = false
	root.effects.hide()
	#root.hitbox.rects = []
	num_hits = 0
	num_contacts = 0
	move_contact = 0
	move_hit = 0
	charge_time = 0
	root.disable_all_actions()
	root.Sprite.flipped_frame_offset = 0
	#_despawn_charge_effect()
	super._exit(next_state)
	#if next_state.name == "Dash":
	#	root.use_energy(1)
	#if next_state.name.ends_with(" Special"):
	#	root.use_energy(1)
	#root.attack_trail.trail_state = {}
	#root.attack_trail.clear_trail()


## Manually sets the phase to another one in the move, using an index
func change_phase(phase_index: int) -> void:
	if phase_index < 0 or phase_index > _phases.size()-1:
		push_error("Phase out of bounds.")
	var previous_phase_index: int = current_phase_index
	current_phase_index = phase_index
	
	# Reset phase timer
	_phase_timer = 0
	_current_phase_loop = false
	_current_animation = ""
	_current_section_start = -1
	_current_section_end = -1
	
	# If we went backwards to a previous phase, previous phase index is now invalid
	if previous_phase_index > phase_index:
		previous_phase_index = -1
		
	var current_phase: AttackPhase = get_current_phase() as AttackPhase
	var previous_phase: AttackPhase = get_phase(previous_phase_index)
	
	if use_hitbox:
		root.hitbox.active = current_phase.hitbox_active
	#root.animsprite.offset = Vector2(0,0)
	
	# Charging - WIP
	#if previous_phase_index > -1:
		#if previous_phase.phase_type == AttackPhase.PHASE_TYPE.CHARGE:
			#if charge_time >= 8:
				#get_hit_data().charge_percent = Functions.fixed_to_hundred(SGFixed.div(
						#charge_time * 65536, previous_phase.max_charge * 65536))
			#_despawn_charge_effect()
	
	#if current_phase.use_charge_effect:
		#_spawn_charge_effect()
	
	# Decide phase duration
	# If the move missed, make phase longer
	var calculated_frames: int = current_phase.frames
	if current_phase.add_whiff_lag:
		if move_hit == 0:
			calculated_frames = int(calculated_frames * 1.5)#SGFixed.to_int(SGFixed.mul(65536 * calculated_frames , 98304)) #1.5
	
	_phase_timer = calculated_frames
	
	if current_phase.sound_effect != "":
		root.play_sound_effect(current_phase.sound_effect)
	if current_phase.voice_clip != "":
		root.play_voice_clip(current_phase.voice_clip)
	
	# Animation
	if play_animation:
		var animation_name: String = animation
		if change_anim_in_air and !root.is_on_floor():
			animation_name = air_animation
		if animation_down and attack_direction == Vector2.DOWN:
			animation_name = animation_down
		if animation_up and attack_direction == Vector2.UP:
			animation_name = animation_up
			
		if current_phase.anim_override:
			if root.is_on_floor():
				animation_name = current_phase.anim_override
			else:
				animation_name = current_phase.air_anim_override
		
		# Automatically speed up/slow down animations according to the phase frames
		if use_sections:
			var speed: float = 1.0
			var section_start: float
			var section_end: float
			var loop: bool = false
			if use_anim_markers:
				var animation: Animation = root.animplayer.get_animation(animation_name)
				if animation:
					var markers: PackedStringArray = animation.get_marker_names()
					var start_marker: String = current_phase.anim_marker
					var start_marker_idx: int = markers.find(start_marker)
					# Check if the marker is using loop
					if start_marker_idx == -1:
						start_marker_idx = markers.find(start_marker + "_loop")
						# If loop marker was found
						if start_marker_idx != -1:
							loop = true
							_current_phase_loop = true
							start_marker = start_marker + "_loop"
					var end_marker: String = ""
					if start_marker_idx < markers.size() - 1:
						end_marker = markers[start_marker_idx + 1]
					section_start = animation.get_marker_time(start_marker)
					if end_marker:
						section_end = animation.get_marker_time(end_marker) - 0.001
						# Check if the next section is the looping section
						if end_marker == start_marker + "_loop" and !loop:
							loop = true
							_current_phase_loop = true
					else:
						section_end = animation.length
			else:
				section_start = current_phase.anim_frame_start * tick_time
				section_end = current_phase.anim_frame_end * tick_time

			var section_length = section_end - section_start
			# Dont slow down animation if using loop
			if not is_equal_approx(section_length, current_phase.frames * tick_time) and not loop:
				speed = section_length/float(current_phase.frames * 0.016)
			if use_sections:
				root.animplayer.play_section(animation_name, section_start, section_end, -1, speed)
			
			_current_animation = animation_name
			_current_section_start = section_start
			_current_section_end = section_end
		else:
			root.animplayer.play(animation_name)
			_current_animation = animation_name
			_current_section_start = -1
			_current_section_end = -1
		
		# Calculate flipped frame offset, for attacks with up and down directions
		var offset: int
		if animation_name == animation_up:
			offset = animation_down_start_frame - animation_up_start_frame
		if animation_name == animation_down:
			offset = animation_up_start_frame - animation_down_start_frame
		
		_flipped_frame_offset = offset
	

		
	_phase_changed_internal(phase_index, previous_phase_index)
	_phase_changed()


func change_phase_to(phase: AttackPhase) -> void:
	change_phase(_phases.find(phase))


## Call this to change to the next phase
## Can be called manually to end the current phase before the phase timer ends
func next_phase() -> void:
	# Skip phase if it has 0 frames
	# if _phases[current_phase_index + 1].frames == 0:
	# 	if _phases[current_phase_index + 1].end_phase:
	# 		parent.change_state(next_state, next_state_data)
	# 		return
	# 	current_phase_index += 1
	change_phase(current_phase_index + 1)


## WIP - Call this to stop charging a charge attack
func release_charge() -> void:
	if get_current_phase().phase_type == AttackPhase.PHASE_TYPE.CHARGE:
		next_phase()


func get_current_phase() -> AttackPhase:
	return _phases[current_phase_index]


func get_current_phase_name() -> String:
	return _phases[current_phase_index].phase_name


func get_current_phase_time() -> int:
	return (get_current_phase().frames - _phase_timer)


func get_phase(index: int) -> AttackPhase:
	return _phases[index]


func get_phase_by_name(p_phase_name: String) -> AttackPhase:
	for phase in _phases:
		# Phases with empty names cannot be retrieved up by name
		if phase.phase_name == "":
			continue
		if phase.phase_name == p_phase_name:
			return phase
	return null


## Adds an AttackPhase object into the move at a certain index
func add_phase(phase: AttackPhase, index: int = -1) -> void:
	if index == -1:
		_phases.append(phase)
	else:
		_phases.insert(index, phase)


## Creates a new AttackPhase object using the given name, then inserts it
func add_new_phase(p_name: String = "", index: int = -1) -> AttackPhase:
	var phase = AttackPhase.new(p_name)
	add_phase(phase, index)
	return phase


func remove_phase(index: int) -> void:
	_phases.remove_at(index)


func erase_phase(phase: AttackPhase) -> void:
	_phases.erase(phase)


func get_array_idx_or_back(array: Array, index: int):
	if array.is_empty():
		return null
	return array[min(index, array.size()-1)]
	


func add_standard_attack_phases(charge: bool = false, whiff_lag: bool = false) -> PhaseSet:
	var phase_set := PhaseSet.new()
	# Set up default phases (Charge, Startup, Active, Recovery)
	if charge and root.is_in_group("fighter"):
		phase_set.charge.use_charge_effect = true
	phase_set.recovery.add_whiff_lag = whiff_lag
	add_phase_set(phase_set, charge)
	return phase_set


## Creates multiple sets of standard phases that link into each other
## If "jab" is true, button must be pressed repeatedly to link attacks
func add_multi_attack_phases(attacks: int = 3, jab: bool = false, whiff_lag: bool = false) -> PhaseSetArray:
	var phase_set_array := PhaseSetArray.new()
	for i in range(attacks):
		var phase_set := PhaseSet.new()
		phase_set.startup.phase_name += str(i + 1)
		phase_set.active.phase_name += str(i + 1)
		phase_set.recovery.phase_name += str(i + 1)
		phase_set.recovery.add_whiff_lag = whiff_lag
		if i < attacks-1:
			if jab:
				phase_set.recovery.end_phase = true
				phase_set.recovery.phase_type = AttackPhase.PHASE_TYPE.JAB
		else:
			phase_set.recovery.end_phase = true
		add_phase_set(phase_set)
		phase_set_array.phase_sets.append(phase_set)
	return phase_set_array


func add_phase_set(phase_set: PhaseSet, charge: bool = false):
	if charge:
		add_phase(phase_set.charge)
	phase_set.recovery.end_phase = true
	add_phase(phase_set.startup)
	add_phase(phase_set.active)
	add_phase(phase_set.recovery)


# Applies attack info to the root Hitbox's HitData
func apply_hit_data():
	get_hit_data().damage = attack_info.damage
	get_hit_data().knockback_power = attack_info.knockback_power
	get_hit_data().knockback_angle = attack_info.knockback_angle
	get_hit_data().knockback_type = attack_info.knockback_type
	get_hit_data().hit_stun = attack_info.hit_stun


## When the player hits an opponent, the hitbox deactivates automatically, use this to reactivate it for a multi-hitting attack
func reactivate_hitbox() -> void:
	root.hitbox.active = true


func attack_phase_from_dict(dict: Dictionary) -> AttackPhase:
	var attack_phase := AttackPhase.new("")
	for property in dict.keys():
		attack_phase.set(property, dict[property])
	return attack_phase


func _save_state() -> Dictionary:
	var state = super._save_state()
	var new_state = {
		use_air_animation = _use_air_animation,
		current_phase_index = current_phase_index,
		charge_time = charge_time,
		move_hit = move_hit,
		move_contact = move_contact,
		num_hits = num_hits,
		num_contacts = num_contacts,
		next_state = next_state,
		#charge_effect_path = _charge_effect_path,
		phase_timer = _phase_timer,
	}
	
	state.merge(new_state)
	return state.duplicate(true)


func _load_state(state: Dictionary):
	super._load_state(state)
	_use_air_animation = state["use_air_animation"]
	current_phase_index = state["current_phase_index"]
	move_contact = state["move_contact"]
	charge_time = state["charge_time"]
	move_hit = state["move_hit"]
	num_hits = state["num_hits"]
	num_contacts = state["num_contacts"]
	_phase_timer = state["phase_timer"]
	#_charge_effect_path = state["charge_effect_path"]
