extends BaseAttack
class_name BaseAttackStandard
enum AttackTemplate {NONE, STANDARD, MULTI}

# For Attack Templates
var attack_template: int = AttackTemplate.NONE
var startup_frames: int = 2
var active_frames: int = 2
var recovery_frames: int = 10
var startup_anim_frame_start: int = 0
var startup_anim_frame_end: int = 0
var active_anim_frame_start: int = 0
var active_anim_frame_end: int = 0
var recovery_anim_frame_start: int = 0
var recovery_anim_frame_end: int = 0
# Split up the animation into the startup, active, and recovery sections
var whiff_lag: bool = false
var attack_sound: String = "punch_light"
var damage: int = 15
var knockback_power: int = 25
var knockback_angle: int = -35
var knockback_direction: Vector2 = Vector2.ZERO
var knockback_type: HitData.KNOCKBACK_TYPE = HitData.KNOCKBACK_TYPE.WEAK
var hit_stun: int = 30
var hit_sound: String = "punch_light"
var can_charge: bool = false
var max_charge: int = 30
var max_hold: int = 30
var knockback_charge_scale: int = 180
var damage_charge_scale: int = 150
var knockback_scaling_charge_scale: int = 180
var auto_set_hit_data: bool = true
var charge_phase: AttackPhase
var startup_phase: AttackPhase
var active_phase: AttackPhase
var recovery_phase: AttackPhase

# For multi attacks (more than one set of startup, active, recovery)
var multi_attack_count: int = 3
var is_jab_combo: bool = false 
var attack_sound_array: Array[String]
var startup_frames_array: Array[int]
var active_frames_array: Array[int]
var recovery_frames_array: Array[int]
var damage_array: Array[int]
var knockback_power_array: Array[int]
var knockback_angle_array: Array[int]
var knockback_scaling_array: Array[int]
var hit_sound_array: Array[String]
var first_attacks_ignore_damage: bool = true
var first_attacks_knockback: int = 10
var first_attacks_knockback_angle: int = -1
var startup_phase_array := []
var active_phase_array := []
var recovery_phase_array := []


func _phase_changed_internal(phase_index: int, previous_phase_index: int):
	super._phase_changed_internal(phase_index, previous_phase_index)
	if auto_set_hit_data:
		if attack_template == AttackTemplate.STANDARD:
			if get_current_phase() == active_phase:
				get_hit_data().damage = damage
				get_hit_data().knockback_power = knockback_power
				get_hit_data().knockback_angle = knockback_angle
				get_hit_data().knockback_type = knockback_type
				get_hit_data().hit_stun = hit_stun
				#get_hit_data().knockback_direction = knockback_direction
				#get_hit_data().knockback_scaling = knockback_scaling
				#get_hit_data().damage_charge_scale = damage_charge_scale
				#get_hit_data().knockback_charge_scale = knockback_charge_scale
				#get_hit_data().knockback_scaling_charge_scale = knockback_scaling_charge_scale
				#get_hit_data().sound = hit_sound
			# Player can cancel into other attacks when recovery phase starts
			if get_current_phase() == recovery_phase:
				root.set_action_enabled("attack", true)
		if attack_template == AttackTemplate.MULTI:
			if get_current_phase() != active_phase_array.back():
				if first_attacks_ignore_damage:
					get_hit_data().ignore_damage = true
			if get_current_phase() in active_phase_array:
				var i: int = 0
				for phase in active_phase_array:
					if phase == get_current_phase():
						break
					i += 1
				
				if !damage_array.is_empty():
					get_hit_data().damage = get_array_idx_or_back(damage_array, i)
				if !knockback_power_array.is_empty():
					get_hit_data().knockback_power = get_array_idx_or_back(knockback_power_array, i)
				if !knockback_angle_array.is_empty():
					get_hit_data().knockback_angle = get_array_idx_or_back(knockback_angle_array, i)
				if !knockback_scaling_array.is_empty():
					get_hit_data().knockback_scaling = get_array_idx_or_back(knockback_scaling_array, i)
				if !hit_sound_array.is_empty():
					get_hit_data().sound = get_array_idx_or_back(hit_sound_array, i)


func make_standard_attack() -> void:
	if can_charge:
		charge_phase = AttackPhase.new("charge")
		charge_phase.phase_type = AttackPhase.PHASE_TYPE.CHARGE
		charge_phase.max_charge = max_charge
		charge_phase.max_hold = max_hold
		charge_phase.use_charge_effect = true
		add_phase(charge_phase)
	
	startup_phase = AttackPhase.new("startup")
	startup_phase.frames = startup_frames
	startup_phase.anim_frame_start = startup_anim_frame_start
	startup_phase.anim_frame_end = startup_anim_frame_end
	add_phase(startup_phase)
	
	active_phase = AttackPhase.new("active")
	active_phase.frames = active_frames
	active_phase.hitbox_active = true
	active_phase.sound_effect = attack_sound
	active_phase.anim_frame_start = active_anim_frame_start
	active_phase.anim_frame_end = active_anim_frame_end
	add_phase(active_phase)
	
	recovery_phase = AttackPhase.new("recovery")
	recovery_phase.frames = recovery_frames
	recovery_phase.add_whiff_lag = whiff_lag
	recovery_phase.end_phase = true
	add_phase(recovery_phase)
	
	attack_template = AttackTemplate.STANDARD


func make_multi_attack():
	if can_charge and root.is_in_group("fighter"):
		charge_phase = AttackPhase.new("charge")
		charge_phase.phase_type = AttackPhase.PHASE_TYPE.CHARGE
		charge_phase.max_charge = max_charge
		charge_phase.max_hold = max_hold
		charge_phase.use_charge_effect = true
		add_phase(charge_phase)
	
	for i in range(multi_attack_count):
		var current_startup_phase := AttackPhase.new("startup" + str(i + 1))
		current_startup_phase.frames = get_array_idx_or_back(startup_frames_array, i)
		startup_phase_array.append(current_startup_phase)
		add_phase(current_startup_phase)
		
		var current_active_phase := AttackPhase.new("active" + str(i + 1))
		current_active_phase.frames = get_array_idx_or_back(active_frames_array, i)
		current_active_phase.hitbox_active = true
		current_active_phase.sound_effect = get_array_idx_or_back(attack_sound_array, i)
		active_phase_array.append(current_active_phase)
		add_phase(current_active_phase)
		
		var current_recovery_phase := AttackPhase.new("recovery" + str(i + 1))
		current_recovery_phase.frames = get_array_idx_or_back(recovery_frames_array, i)
		current_recovery_phase.end_phase = true
		recovery_phase_array.append(current_recovery_phase)
		add_phase(current_recovery_phase)
		
		if i < multi_attack_count-1:
			if is_jab_combo:
				current_recovery_phase.phase_type = AttackPhase.PHASE_TYPE.JAB
			else:
				current_recovery_phase.end_phase = false
	
	attack_template = AttackTemplate.MULTI


func _save_state() -> Dictionary:
	var state = super._save_state()
	var new_state = {
		auto_set_hit_data = auto_set_hit_data,
	}
	
	state.merge(new_state)
	return state.duplicate(true)


func _load_state(state: Dictionary):
	super._load_state(state)
	auto_set_hit_data = state["auto_set_hit_data"]
