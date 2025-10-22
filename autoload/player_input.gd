# Helper class to get player-specific input for menus
# In game, a function on base_player.gd will be used instead.
extends Node


func player_action_pressed(action: StringName, player_no: int):
	return Input.is_action_pressed(action + str(player_no))


func player_action_just_pressed(action: StringName, player_no: int):
	return Input.is_action_just_pressed(action + str(player_no))


func player_action_just_released(action: StringName, player_no: int):
	return Input.is_action_just_released(action + str(player_no))
