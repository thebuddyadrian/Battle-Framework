extends Control

# If there's a player selecting a character using this node
var active: bool = false: set = set_active
var character_index: int = 0 : set = set_character_index
var character: String : set = set_character

@export var player_number: int = 1
@onready var character_selected: Label = $CharacterSelected
@onready var reference_rect: ReferenceRect = $ReferenceRect
@onready var player_name: Label = $PlayerName
@onready var character_portrait: TextureRect = $Portrait_Manager/Characters
@onready var pixelate: AnimationPlayer = $Portrait_Manager/pixelate
@export var Empty_Portait_Texture:Texture2D = preload("res://characters/base_player/sprites/UnkownPortrait.png")


signal selection_finished


func _ready() -> void:
	#player_name.text = "Player " + str(player_number)
	set_active(active)
	set_character_index(character_index)
	# Make sure the shader material isn't shared between characters
	character_portrait.material = character_portrait.material.duplicate()
	


func _process(delta: float) -> void:
	if active:
		if Input.is_action_just_pressed("ui_left"):
			character_index -= 1
		if Input.is_action_just_pressed("ui_right"):
			character_index += 1
		if Input.is_action_just_pressed("ui_accept"):
			selection_finished.emit()


func set_active(p_active: bool):
	active = p_active
	reference_rect.visible = active


func set_character_index(p_index: int):
	character_index = p_index
	#Reference character List
	var RefCharacters = Lists.characters + Lists.modded_characters
	
	if character_index < 0:
		character_index = RefCharacters.size() - 1
	if character_index >= RefCharacters.size():
		character_index = 0
	set_character(RefCharacters[character_index])


func set_character(p_character: String):
	character = p_character
	character_selected.text = "Character:\n" + (Lists.character_display_names.merged(Lists.modded_char_display_names))[character]
	pixelate.stop()
	pixelate.play("pixelate")
	await get_tree().create_timer(0.4).timeout
	var PortraitList = Lists.Character_Portrait_texture.merged(Lists.modded_Char_Portrait_texture)
	if(PortraitList.has(character)):
		character_portrait.texture = Lists.Character_Portrait_texture.merged(Lists.modded_Char_Portrait_texture)[character]
	else:
		character_portrait.texture = Empty_Portait_Texture
