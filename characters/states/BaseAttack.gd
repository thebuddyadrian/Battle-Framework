@tool
extends BaseState
class_name BaseAttack

enum DIR_TYPE {TWO_DIR, FOUR_DIR}

const DEFAULT_STARTUP_FRAMES: int = 2
const DEFAULT_ACTIVE_FRAMES: int = 2
const DEFAULT_RECOVERY_FRAMES: int = 10

var next_state: String = "Idle"
var next_state_data: Dictionary = {}
var animation: String = ""
var air_animation: String = ""
var change_anim_in_air: bool = false

var charge_time: int = 0
var current_phase_index: int = -1
var move_contact: int = 0
var move_hit: int = 0
var move_blocked: int = 0
var num_hits: int = 0
var num_contacts: int = 0
var num_blocked: int = 0

# Whole Move Config
var land_on_touched_ground: bool = false
#var stay_on_ground: bool = false
var landing_lag: int = 6
var dash_cancel: bool = false
var special_cancel: bool = false
var hitfall: bool = false
var play_animation: bool = true
var use_anim_markers: bool = true
var direction_type: DIR_TYPE = DIR_TYPE.TWO_DIR


var _charge_effect_path: NodePath = ""
var _use_air_animation: bool = false
var _phases := []
var _phases_dict := {}
var _phase_timer: int = 0


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


class AttackPhase:
	# NORMAL: Automatically switch to next phase when phase timer ends
	# CHARGE: Switch to next phase when attack button released, then set charge_time
	# JAB: If the attack button is pressed during this frame, go to next phase
	# RAPID: If the attack button is not pressed for a few frames, switch to next phase
	# MANUAL: Attack will not go to next phase automatically
	# Only applies if the root is a BaseFighter
	enum PHASE_TYPE {NORMAL, CHARGE, JAB, RAPID, MANUAL}
	# LAST_FRAME: Do nothing
	# FIRST FRAME: Hold at the first frame if the animation is too short
	# Scale: Make the animation slower or faster depending on how many frames
	var phase_name: String = ""
	var phase_type: int = PHASE_TYPE.NORMAL
	var frames: int = 0
	var anim_override: String = ""
	var air_anim_override: String = ""
	var anim_marker: String = ""
	var anim_frame_start: int = 0
	var anim_frames: int = 0 : get = get_frames, set = set_frames
	var anim_frame_end: int = 0
	var add_whiff_lag: bool = false
	var end_phase: bool = false
	var sound_effect: String = ""
	var sound_offset: int = 0
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
	clear_phases()
	_move_setup()
	_check_for_end_phase()
	#if root.is_in_group("fighter"):
		#root.face_attack_direction()
		#root.attack_trail.trail_state = {}
	root.hitbox.active = true
	#root.hitbox.rects = []
	root.hitbox.hit_data = HitData.new()
	root.update_facing_direction_2d()
	if direction_type == DIR_TYPE.FOUR_DIR:
		root.hitbox.hit_data.knockback_direction = root.facing_direction
		root.hitbox.rotation.y = -root.facing_direction.angle()
		print(rad_to_deg(root.facing_direction.angle()))
	else:
		root.hitbox.hit_data.knockback_direction.x = root.facing_direction_2d
		root.hitbox.hit_data.knockback_direction.y = 0
		root.hitbox.rotation_degrees.y = 180 if root.facing_direction_2d == -1 else 0
	#root.hitbox.hit_data.charge_percent = 0
	num_hits = 0
	num_contacts = 0
	move_contact = 0
	move_hit = 0
	charge_time = 0
	_phase_timer = 0
	change_phase(0)


# Called when the player should set up the attack phases
func _move_setup():
	pass


func _check_for_end_phase():
	for phase in _phases:
		if phase.end_phase:
			return
	assert(false, "This attack has no end phase!")


func _step():
	if root.is_in_group("characters"):
		if (get_current_phase().land_on_touched_ground or land_on_touched_ground) and root.is_on_floor():
			parent.change_state("Land", {landing_frames = max(get_current_phase().landing_frames, landing_lag)})
			return
		
		## Charging
		#if get_current_phase().phase_type == AttackPhase.PHASE_TYPE.CHARGE:
			#charge_time = min(charge_time + 1, 
					#get_current_phase().max_charge)
			#if charge_time >= get_current_phase().max_hold:
				#release_charge()
			#if !root.input_attack("pressed"):
				#release_charge()
		
		# Jabs
		# Cancel into next phase when attack pressed
		if get_current_phase().phase_type == AttackPhase.PHASE_TYPE.JAB:
			var transition_offset = get_current_phase().jab_transition_offset
			if move_contact == 0:
				transition_offset = get_current_phase().jab_transition_offset_whiff
			if _phase_timer <= get_current_phase().frames - transition_offset or _phase_timer <= 2:
				if root.input_attack("pressed"):
					root.stop_buffer_attack("pressed")
					root.stop_buffer("special", "pressed")
					next_phase()
	
	if _phase_timer > 0:
		_phase_timer = max(0, _phase_timer - 1)
		if _phase_timer == 0:
			if get_current_phase().end_phase:
				parent.change_state(next_state, next_state_data)
				return
			next_phase()
	
func _step_frozen():
	#Count up move_hit and move_contact
	if move_hit > 0:
		move_hit += 1
	
	if move_contact > 0:
		move_contact += 1
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
	#get_hit_data().ignore_damage = false
	pass

	
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


func hitbox_hit(hit_data: HitData, area_hit):
	num_hits += 1
	move_hit = 1
	num_contacts += 1
	move_contact = 1


func _exit(next_state):
	root.hitbox.active = false
	#root.hitbox.rects = []
	num_hits = 0
	num_contacts = 0
	move_contact = 0
	move_hit = 0
	charge_time = 0
	if root.is_in_group("fighter"):
		root.set_barrier_collision(false)
		root.disable_all_actions()
	#_despawn_charge_effect()
	super._exit(next_state)
	#if next_state.name == "Dash":
	#	root.use_energy(1)
	#if next_state.name.ends_with(" Special"):
	#	root.use_energy(1)
	#root.attack_trail.trail_state = {}
	#root.attack_trail.clear_trail()


func change_anim(new_anim: String):
	if new_anim != "":
		if change_anim_in_air and !root.is_on_floor():
			root.animplayer.stop()
			root.animplayer.play(new_anim + " Air")

		else:
			root.animplayer.stop()
			root.animplayer.play(new_anim)
			root.animplayer.seek(0)


func change_phase(phase_index: int) -> void:
	if phase_index < 0 or phase_index > _phases.size()-1:
		push_error("Phase out of bounds.")
	var previous_phase_index: int = current_phase_index
	current_phase_index = phase_index
	
	# Reset phase timer
	_phase_timer = 0
	
	# Make sure previous phase index is correct
	if previous_phase_index > phase_index:
		previous_phase_index = -1
		
	var current_phase: AttackPhase = get_current_phase() as AttackPhase
	var previous_phase: AttackPhase = get_phase(previous_phase_index)
	
	root.hitbox.active = current_phase.hitbox_active
	#root.animsprite.offset = Vector2(0,0)
	
	## Charging
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
	
	# Sound Effects
	#if current_phase.sound_effect != "":
	#	root.play_sound_fx("Attack/%s" % current_phase.sound_effect)
	
	# Animation
	if play_animation:
		var animation_name: String = animation
		if change_anim_in_air and !root.is_on_floor():
			animation_name = air_animation
		if current_phase.anim_override:
			if root.is_on_floor():
				animation_name = current_phase.anim_override
			else:
				animation_name = current_phase.air_anim_override
		
		# Automatically speed up/slow down animations according to the phase frames
		var speed: float = 1.0
		var section_start: float
		var section_end: float
		if use_anim_markers:
			var animation: Animation = root.animplayer.get_animation(animation_name)
			var markers: PackedStringArray = animation.get_marker_names()
			var start_marker: String = current_phase.anim_marker
			var start_marker_idx: int = markers.find(start_marker)
			var end_marker: String = ""
			if start_marker_idx < markers.size() - 1:
				end_marker = markers[start_marker_idx + 1]
			section_start = animation.get_marker_time(start_marker)
			if end_marker:
				section_end = animation.get_marker_time(end_marker)
			else:
				section_end = animation.length
			print(current_phase.phase_name)
			print("Start Marker: %s" % start_marker)
			print("End Marker: %s" % end_marker)
			print("Section Start: %s" % section_start)
			print("Section End: %s" % section_end)
		else:
			section_start = current_phase.anim_frame_start * tick_time
			section_end = current_phase.anim_frame_end * tick_time
		var section_length = section_end - section_start
		if not is_equal_approx(section_length, current_phase.frames * tick_time):
			speed = section_length/float(current_phase.frames * 0.016)
		root.animplayer.play_section(animation_name, section_start, section_end, -1, speed)
	_phase_changed_internal(phase_index, previous_phase_index)
	_phase_changed()


func resume_animation(animation_name: String, phase_index: int):
	if current_phase_index != phase_index:
		return
	root.animplayer.play(animation_name)


func change_phase_to(phase: AttackPhase) -> void:
	change_phase(_phases.find(phase))


func next_phase() -> void:
	# Skip phase if it has 0 frames
	if _phases[current_phase_index + 1].frames == 0:
		current_phase_index += 1
	change_phase(current_phase_index + 1)


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


func add_phase(phase: AttackPhase, index: int = -1) -> void:
	if index == -1:
		_phases.append(phase)
	else:
		_phases.insert(index, phase)


func add_new_phase(p_name: String = "", index: int = -1) -> AttackPhase:
	var phase = AttackPhase.new(p_name)
	add_phase(phase, index)
	return phase


func remove_phase(index: int) -> void:
	_phases.remove_at(index)


func erase_phase(phase: AttackPhase) -> void:
	_phases.erase(phase)


func clear_phases() -> void:
	_phases = []


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


# Creates multiple sets of standard phases that link into each other
# If "jab" is true, button must be pressed repeatedly to link attacks
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
		charge_effect_path = _charge_effect_path,
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
	_charge_effect_path = state["charge_effect_path"]
