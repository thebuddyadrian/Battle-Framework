extends BattleCharacter


#Right now Knuckles skills are hardcoded, this will be removed when the skill select menu is added
func _check_for_ground_special():
	if input("skill", "just_pressed") and !state_machine.active_state is BaseAttack:
		state_machine.change_state("GrndPow")
		return true
	return false


func _check_for_air_special():
	if input("skill", "just_pressed") and !state_machine.active_state is BaseAttack:
		state_machine.change_state("AirShot")
		return true
	return false