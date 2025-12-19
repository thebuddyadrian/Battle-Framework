extends Control

signal request_cursor_anim(anim_name)

# If there's a player selecting a character using this node
var active: bool = false: set = set_active
var is_cpu: bool = false
var character_index: int = 0 : set = set_character_index
var character: String : set = set_character

var css_ready : bool = false


@export var player_number: int = 1

@onready var character_selected: Label = $CharacterSelected
@onready var reference_rect: ReferenceRect = $ReferenceRect
@onready var character_portrait: TextureRect = $Portrait_Manager/Characters
@onready var pixelate: AnimationPlayer = $Portrait_Manager/pixelate
@onready var confirm_sprite : TextureRect = $ConfirmSprite
@onready var cursor_arrows: Control = $CursorArrows
@onready var cursor_arrows_animplayer: AnimationPlayer = $CursorArrows/AnimationPlayer

signal selection_finished(plrnum)


func _ready() -> void:
	#player_name.text = "Player " + str(player_number)
	set_active(active)
	set_character_index(character_index)
	# Make sure the shader material isn't shared between characters
	character_portrait.material = character_portrait.material.duplicate()

	if MatchSetup.is_playing_solo() or is_cpu:
		cursor_arrows.visible = false


func _process(delta: float) -> void:
	if !active:
		return
	if get_input("left"):
		character_index -= 1
		play_cursor_anim("ArrowBumpLeft")
	if get_input("right"):
		character_index += 1
		play_cursor_anim("ArrowRightBump")
	if get_input("attack"):
		selection_finished.emit(player_number)
		confirm_sprite.visible = true
		cursor_arrows.visible = false


func get_input(action: String) -> bool:
	# If this is a CPU player, use player 1 controls
	var input_player_number: int = player_number if !is_cpu else 1
	return PlayerInput.player_action_just_pressed(action, input_player_number)


func play_cursor_anim(anim):
	if MatchSetup.is_playing_solo():
		request_cursor_anim.emit(anim)
	else:
		var animplayer = cursor_arrows.get_node("AnimationPlayer")
		animplayer.stop()
		animplayer.play(anim)


func set_active(p_active: bool):
	active = p_active
	reference_rect.visible = active


func set_character_index(p_index: int):
	character_index = p_index
	if character_index < 0:
		character_index = GameData.characters.size() - 1
	if character_index >= GameData.characters.size():
		character_index = 0
	set_character(GameData.characters[character_index])


func set_character(p_character: String):
	# Load texture for already selected character, in case the last transition was interrupted
	if character != "":
		var old_character_info: CharacterInfo = GameData.get_character_info(character)
		if character_portrait.texture.resource_path != old_character_info.portrait_path:
			character_portrait.texture = load(old_character_info.portrait_path)

	character = p_character
	character_selected.text = "Character:\n" + GameData.get_character_info(character).display_name
	var character_info: CharacterInfo = GameData.get_character_info(character)
	pixelate.stop()
	pixelate.play("pixelate")
	await get_tree().create_timer(0.4).timeout
	character_portrait.texture = load(character_info.portrait_path)


func load_character_portrait(p_character: String):
	var character_info: CharacterInfo = GameData.get_character_info(p_character)
	character_portrait.texture = load(character_info.portrait_path)
