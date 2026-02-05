## Autoload script that stores the match configuration, or the info needed to set up a match in MatchScene
extends Node

var human_players: int = 0
var cpu_players: int = 0
# Stores each player's character choice (maps Player Number -> Character Name)
var character_choices: Dictionary[int, String]= {}
# Stores the stages selected in the Map Select screen
var stage_list: Array = ["battlehwy"]
# The current stage in the list that will be used
var current_stage_index: int = 0
var single_window: bool = true

# Helper function to get total amount of players (human + cpu)
func get_total_players() -> int:
	return (human_players + cpu_players)


func is_playing_solo() -> bool:
	return (human_players == 1)