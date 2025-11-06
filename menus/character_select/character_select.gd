extends Control

const PLAYER_CHARACTER_SCENE := preload("res://menus/character_select/player_character/player_character.tscn")

@onready var player_container: GridContainer = $CSS/PlayerContainer
@onready var CursorArrows : Control = $CSS/CursorArrows
var current_player = 1

var localMultiplayer : bool = false



#to do list:
#   Placeholder Map Select
#   Placeholder Rules Select
#   Replace Buttons on screen with actions on controller input
#   Make sure CSS doesn't get "lost" while showing and hiding these nodes!
#   Adrian if you read this let me know what you think please thank you!! -rash



func _ready() -> void:
	if Game.human_players >= 2:
		localMultiplayer = true
		CursorArrows.visible = false
	
	MusicPlayer.play_track(MusicPlayer.CHALLENGE_BATTLE_MODE)
	var p1node
	for i in range(Game.get_total_players()):
		print(i)
		var player_character = PLAYER_CHARACTER_SCENE.instantiate()
		player_character.name = "PlayerContainer" + str(i + 1)
		player_character.player_number = i + 1
		player_container.add_child(player_character)
		if i == 0 and !localMultiplayer:
			player_character.active = true
			p1node = player_character
			#print(GameData.get_character_info("sonic"))
		elif localMultiplayer:
			player_character.active = true
		#CSSCursorTweenToPlayer(p1node.global_position)
	
	for player in player_container.get_children():
		player.connect("selection_finished", Callable(self, "_on_player_selection_finished"))
		player.connect("RequestCursorAnim", PlayCursorAnim)
	
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
	CSSCursorTweenToPlayer(current_player_node.global_position)
	print(current_player)

func CSSCursorTweenToPlayer(playerposition):
	var newTween = get_tree().create_tween()
	newTween.tween_property(CursorArrows, "global_position", playerposition, 0.1)
	
	newTween.play()

func PlayCursorAnim(anim):
	var animplayer = CursorArrows.get_node("AnimationPlayer")
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
