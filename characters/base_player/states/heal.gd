extends BaseState


var startup: int = 8
var recovery: int = 6
var effect_instance: BaseEffect
var in_recovery: bool = false

func _enter(data = {}):
	in_recovery = false


func _step():
	if parent.state_time <= startup:
		root.animplayer.play_section_with_markers("Heal", "HealStartup", "HealLoop")
	elif in_recovery:
		root.animplayer.play_section_with_markers("Heal", "HealEnd", "")
	else:
		root.animplayer.play_section_with_markers("Heal", "HealLoop", "HealEnd")
		if parent.state_time % 20  == 0:
			root.current_hp = min(root.current_hp + 2, root.max_hp)
			root.play_sound_effect("heal")

		if !root.input("guard", "pressed"):
			in_recovery = true
			parent.make_timer("go_to_idle", recovery, self)
			return
	
	if parent.state_time == startup:
		# Spawn Heal Effect
		effect_instance = root.spawn_scene("HealEffect", "res://effects/heal_effect.tscn", root.global_position)


func go_to_idle():
	change_state("Idle")


func _exit(next_state):
	if effect_instance:
		effect_instance.queue_free()
		effect_instance = null
