extends Control

@onready var winner_portrait: TextureRect = $WinnerPortrait
@onready var winner_info: Label = $WinnerInfo
@onready var other_player_info: Label = $OtherPlayerInfo

@export var test_players: Array[String] = ["sonic", "tails", "knuckles", "shadow"]

func _ready() -> void:
	# If no players are present, inject fake results and character choices
	if MatchSetup.get_total_players() == 0:
		for i in range(test_players.size()):
			Game.match_results[i + 1] = i + 1
			MatchSetup.character_choices[i + 1] = test_players[i]
		MatchSetup.human_players = test_players.size()

	var player_order: Array[int]
	player_order.resize(MatchSetup.get_total_players()) # This must be changed later when CPUs are added
	for player_id in Game.match_results.keys():
		var rank: int = Game.match_results[player_id]
		player_order[rank - 1] = player_id
	
	var winner_player_id = player_order.pop_front() # Removes the winner from the array
	var winner_character = MatchSetup.character_choices[winner_player_id]
	var winner_character_display_name =  GameData.get_character_info(winner_character).display_name
	winner_info.text = "1st\nPlayer %s - %s" % [winner_player_id, winner_character_display_name]

	# TO-DO, once each character has a CharacterInfo resource, grab portraits from that instead
	if winner_character == "sonic":
		winner_portrait.texture = load("res://characters/sonic/sprites/Sonic Portrait.png")
	elif winner_character == "tails":
		winner_portrait.texture = load("res://characters/tails/sprites/Tails Portrait.png")
	elif winner_character == "knuckles":
		winner_portrait.texture = load("res://characters/knuckles/sprites/Knuckles Portrait.png")
	elif winner_character == "shadow":
		winner_portrait.texture = load("res://characters/shadow/sprites/Shadow Portrait.png")
	
	for player_id in player_order:
		var rank: int = Game.match_results[player_id]
		var rank_string: String
		var character = MatchSetup.character_choices[player_id]
		var character_display_name =  GameData.get_character_info(character).display_name
		if rank == 2:
			rank_string = "2nd"
		elif rank == 3:
			rank_string = "3rd"
		elif rank == 4:
			rank_string = "4th"
		else:
			assert(false, "Invalid rank: %s" % rank)
		other_player_info.text += "%s: Player %s - %s\n" % [rank_string, player_id, character_display_name]


func _on_back_button_pressed() -> void:
	SceneChanger.change_scene_to_file("res://menus/mode_select.tscn")
