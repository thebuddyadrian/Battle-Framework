extends Control

const PLAYER_CHARACTER_SCENE := preload("res://menus/character_select/player_character/player_character.tscn")

@onready var player_container: GridContainer = $CSS/PlayerContainer
# Arrows for selecting characters in solo play and selecting CPU characters
@onready var cursor_arrows : Control = $CSS/CursorArrows
var current_player = 1



func _ready() -> void:
	if !Game.is_playing_solo():
		cursor_arrows.visible = false
	
	MusicPlayer.play_track(MusicPlayer.CHALLENGE_BATTLE_MODE)
	for i in range(Game.get_total_players()):
		var player_character = PLAYER_CHARACTER_SCENE.instantiate()
		player_character.name = "PlayerContainer" + str(i + 1)
		player_character.player_number = i + 1
		player_container.add_child(player_character)
		if i == 0 and Game.is_playing_solo():
			player_character.active = true
		elif !Game.is_playing_solo():
			player_character.active = true
	
	for player in player_container.get_children():
		player.selection_finished.connect(_on_player_selection_finished)
		player.request_cursor_anim.connect(play_cursor_anim)
	
	for stage in Lists.battle_stages:
		$MAPSELECT/StageSelect.add_item(stage)

	for stage in Lists.modded_battle_stages:
		$MAPSELECT/StageSelect.add_item(stage + " (MOD)")

func _on_player_selection_finished():
	var current_player_node = player_container.get_child(current_player - 1)
	Game.character_choices[current_player] = current_player_node.character
	current_player_node.active = false

	var selected_stage: String
	# If the current selected index is greater than the amount of base stages, it must be a modded stage
	if $MAPSELECT/StageSelect.selected > Lists.battle_stages.size() - 1:
		selected_stage = Lists.modded_battle_stages[$MAPSELECT/StageSelect.selected - Lists.battle_stages.size()]
	else:
		selected_stage = Lists.battle_stages[$MAPSELECT/StageSelect.selected]

	if current_player == Game.human_players + Game.cpu_players:
		SceneChanger.change_scene_to_file("res://levels/%s/%s.tscn" % [selected_stage, selected_stage])
		return
	current_player += 1
	await get_tree().process_frame
	current_player_node = player_container.get_child(current_player - 1)
	current_player_node.active = true
	css_cursor_tween_to_player(current_player_node.global_position)
	print(current_player)

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
	$MAPSELECT.visible = true
	$MapSelectButton.visible = false
	$CSSSelectButton.visible = true
	$CSSSelectButton.position = $MapSelectButton.position
	$RULESELECT.visible = false
	$CSS.visible = false


func _on_rule_select_button_pressed() -> void:
	$CSS.process_mode = Node.PROCESS_MODE_DISABLED
	$MAPSELECT.visible = false
	$RuleSelectButton.visible = false
	$CSSSelectButton.visible = true
	$MapSelectButton.visible = true
	$CSSSelectButton.position = $RuleSelectButton.position
	$RULESELECT.visible = true
	$CSS.visible = false

func _on_css_select_button_pressed() -> void:
	$CSS.process_mode = Node.PROCESS_MODE_INHERIT
	$MAPSELECT.visible = false
	$RuleSelectButton.visible = true
	$MapSelectButton.visible = true
	$CSSSelectButton.visible = false
	$RULESELECT.visible = false
	$CSS.visible = true
