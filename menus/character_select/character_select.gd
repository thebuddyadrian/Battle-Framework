extends Control

const PLAYER_CHARACTER_SCENE := preload("res://menus/character_select/player_character/player_character.tscn")

@onready var player_container: GridContainer = $PlayerContainer
var current_player = 1

func _ready() -> void:
	MusicPlayer.play_track(MusicPlayer.CHALLENGE_BATTLE_MODE)
	for i in range(Game.human_players + Game.cpu_players):
		var player_character = PLAYER_CHARACTER_SCENE.instantiate()
		player_character.name = "PlayerContainer" + str(i + 1)
		player_character.player_number = i + 1
		player_container.add_child(player_character)
		if i == 0:
			player_character.active = true
		
	for player in player_container.get_children():
		player.connect("selection_finished", Callable(self, "_on_player_selection_finished"))


func _on_player_selection_finished():
	var current_player_node = player_container.get_child(current_player - 1)
	Game.character_choices[current_player] = current_player_node.character
	current_player_node.active = false
	if current_player == Game.human_players + Game.cpu_players:
		SceneChanger.change_scene_to_file("res://levels/emeraldbeach/emeraldbeach.tscn")
		return
	current_player += 1
	await get_tree().process_frame
	current_player_node = player_container.get_child(current_player - 1)
	current_player_node.active = true
	print(current_player)
