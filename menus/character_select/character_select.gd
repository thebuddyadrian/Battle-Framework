extends Control

const PLAYER_CHARACTER_SCENE := preload("res://menus/character_select/player_character/player_character.tscn")

@onready var player_container: GridContainer = $CSS/PlayerContainer
# Arrows for selecting characters in solo play and selecting CPU characters
@onready var cursor_arrows : Control = $CSS/CursorArrows
@onready var map_select : Control = $MAPSELECT

var current_player = 1

var active_player_nodes = []

func _ready() -> void:
	map_select.process_mode = Node.PROCESS_MODE_DISABLED
	
	if !MatchSetup.is_playing_solo():
		cursor_arrows.visible = false
	
	MusicPlayer.play_track(MusicPlayer.CHALLENGE_BATTLE_MODE)
	for i in range(MatchSetup.get_total_players()):
		var player_character = PLAYER_CHARACTER_SCENE.instantiate()
		# If this index is above the amount of human players, it must be a CPU
		if i >= MatchSetup.human_players:
			player_character.is_cpu = true
		player_character.name = "PlayerContainer" + str(i + 1)
		player_character.player_number = i + 1
		player_container.add_child(player_character)
		if i == 0 and MatchSetup.is_playing_solo():
			player_character.active = true
			css_cursor_tween_to_player(player_character.global_position)
		elif !MatchSetup.is_playing_solo() and i < MatchSetup.human_players:
			player_character.active = true
	
	for player in player_container.get_children():
		player.selection_finished.connect(_on_player_selection_finished)
		player.request_cursor_anim.connect(play_cursor_anim)
	
	for stage in GameData.battle_stages:
		$MAPSELECT/StageSelect.add_item(stage)

	for stage in GameData.modded_battle_stages:
		$MAPSELECT/StageSelect.add_item(stage + " (MOD)")

func _on_player_selection_finished(plrnum):
	var current_player_node = player_container.get_child(plrnum - 1)
	MatchSetup.character_choices[plrnum] = current_player_node.character
	current_player_node.active = false
	current_player_node.css_ready = true
	
	#changed how it works, i apologize
	
	css_check_for_players_ready()
	
	css_iterate_cpu_players(current_player_node, plrnum)

func css_iterate_cpu_players(node, num):
	print(node, num)
	
	num += 1
	await get_tree().process_frame
	
	if num > MatchSetup.human_players + MatchSetup.cpu_players:
		pass
	else:
		node = player_container.get_child(num - 1)
		#assume that if it is already active, it's another player, not cpu
		if node.active == true:
			# iterate again until you get OOB for the player count.
			css_iterate_cpu_players(node, num)
		else:
			node.active = true
			css_cursor_tween_to_player(node.global_position)

func css_scene_transition():
	var selected_stage: String
	# If the current selected index is greater than the amount of base stages, it must be a modded stage
	if $MAPSELECT/StageSelect.selected > GameData.battle_stages.size() - 1:
		selected_stage = GameData.modded_battle_stages[$MAPSELECT/StageSelect.selected - GameData.battle_stages.size()]
	else:
		selected_stage = GameData.battle_stages[$MAPSELECT/StageSelect.selected]
	
	# Store stage list
	if map_select.selected_stages.size() == 0:
		MatchSetup.stage_list = [selected_stage]
	
	SceneChanger.change_scene_to_file("res://match_scene/match_scene.tscn")


func css_check_for_players_ready():
	#this function needs to iterate when fired across all the players
	#then determine if there is still an active player. 
	#if there are no active players, return true for transition.
	#if there isn't, dont do anything. we'll check again when a player gets selected.
	var player_nodes = player_container.get_children()
	for i in player_nodes:
		if i.css_ready:
			active_player_nodes.append(i)
			if active_player_nodes.size() == player_nodes.size():
				css_scene_transition()
			else:
				print("not enough players")
				return false

func css_cursor_tween_to_player(playerposition):
	var newTween = get_tree().create_tween()
	newTween.tween_property(cursor_arrows, "global_position", playerposition, 0.1)
	
	newTween.play()

func play_cursor_anim(anim):
	var animplayer = cursor_arrows.get_node("AnimationPlayer")
	if animplayer.is_playing():
		animplayer.stop()
		animplayer.play(anim)
	else:
		animplayer.play(anim)

##    VVVV THESE ARE PLACEHOLDER AND NEED TO BE CHANGED WITH BETTER REFS VVVV

func _on_map_select_button_pressed() -> void:
	$CSS.process_mode = Node.PROCESS_MODE_DISABLED
	$MAPSELECT.process_mode = Node.PROCESS_MODE_INHERIT
	$MAPSELECT.visible = true
	$MapSelectButton.visible = false
	$CSSSelectButton.visible = true
	$CSSSelectButton.position = $MapSelectButton.position
	$RULESELECT.visible = false
	$CSS.visible = false
	# Reset stage index when entering map select like in the original
	MatchSetup.current_stage_index = 0


func _on_rule_select_button_pressed() -> void:
	$CSS.process_mode = Node.PROCESS_MODE_DISABLED
	$MAPSELECT.process_mode = Node.PROCESS_MODE_DISABLED
	$MAPSELECT.visible = false
	$RuleSelectButton.visible = false
	$CSSSelectButton.visible = true
	$MapSelectButton.visible = true
	$CSSSelectButton.position = $RuleSelectButton.position
	$RULESELECT.visible = true
	$CSS.visible = false

func _on_css_select_button_pressed() -> void:
	$CSS.process_mode = Node.PROCESS_MODE_INHERIT
	$MAPSELECT.process_mode = Node.PROCESS_MODE_DISABLED
	$MAPSELECT.visible = false
	$RuleSelectButton.visible = true
	$MapSelectButton.visible = true
	$CSSSelectButton.visible = false
	$RULESELECT.visible = false
	$CSS.visible = true
