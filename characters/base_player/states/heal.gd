extends BaseState


var startup: int = 8
var recovery: int = 6


func _enter(data = {}):
	pass


func _step():
	#$"../../PlayerSprite/Misc_Effects".position = Vector3(0.0,0.061,00.0)
	if parent.state_time <= startup:
		root.animplayer.play_section_with_markers("Heal", "HealStartup", "HealLoop")
	else:
		root.animplayer.play_section_with_markers("Heal", "HealLoop", "HealEnd")
		if parent.state_time % 20  == 0:
			root.current_hp = min(root.current_hp + 1, root.HP)
			root.play_sound_effect("heal")

		if !root.input("guard", "pressed"):
			change_state("Idle")
			return
	
