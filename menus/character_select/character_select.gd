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
	
	for stage in Lists.battle_stages:
		$StageSelect.add_item(stage)

	for stage in Lists.modded_battle_stages:
		$StageSelect.add_item(stage + " (MOD)")

func _on_player_selection_finished():
	var current_player_node = player_container.get_child(current_player - 1)
	Game.character_choices[current_player] = current_player_node.character
	current_player_node.active = false

	var selected_stage_name:String = ($StageSelect.get_item_text($StageSelect.selected))
	var selected_stage_location: String = ""
	var ModNameLength:int = " (MOD)".length()
	if(selected_stage_name.ends_with(" (MOD)")):
		selected_stage_name = selected_stage_name.left(-(ModNameLength))
	# If the current selected index is greater than the amount of base stages, it must be a modded stage
	if Lists.modded_battle_stages.has(selected_stage_name):
		selected_stage_location = Lists.modded_battle_stages[selected_stage_name]
		print("NMT ", selected_stage_location)
	else:
		selected_stage_location = ("res://levels/"+Lists.battle_stages[selected_stage_name]+"/"+Lists.battle_stages[selected_stage_name]+".tscn")

	if current_player == Game.human_players + Game.cpu_players:
		SceneChanger.change_scene_to_file(selected_stage_location)
		return
	current_player += 1
	await get_tree().process_frame
	current_player_node = player_container.get_child(current_player - 1)
	current_player_node.active = true
	print(current_player)
