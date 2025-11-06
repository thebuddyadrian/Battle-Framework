extends Control

signal RequestCursorAnim(str)

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
@onready var confirmSprite : TextureRect = $ConfirmSprite
@onready var cursorarrows: Control = $CursorArrows
#@export var portrait_texture : Dictionary = {
	#"sonic": preload("res://characters/sonic/sprites/Sonic Portrait.png"),
	#"tails": preload("res://characters/tails/sprites/Tails Portrait.png"),
	#"knuckles": preload("res://characters/knuckles/sprites/Knuckles Portrait.png"),
	#"shadow": preload("res://characters/shadow/sprites/Shadow Portrait.png")
	#}


signal selection_finished


func _ready() -> void:
	#player_name.text = "Player " + str(player_number)
	set_active(active)
	set_character_index(character_index)
	# Make sure the shader material isn't shared between characters
	character_portrait.material = character_portrait.material.duplicate()
	
	if Game.is_playing_solo():
		cursorarrows.visible = false


func _process(delta: float) -> void:
	if active and Game.is_playing_solo():
		if PlayerInput.player_action_just_pressed("left", player_number):
			character_index -= 1
			localMultiplayerPlayCursorAnim("ArrowBumpLeft")
		if PlayerInput.player_action_just_pressed("right", player_number):
			character_index += 1
			localMultiplayerPlayCursorAnim("ArrowRightBump")
		if PlayerInput.player_action_just_pressed("attack", player_number):
			selection_finished.emit()
			confirmSprite.visible = true
			cursorarrows.visible = false
	elif active and !Game.is_playing_solo():
		if Input.is_action_just_pressed("left1"):
			character_index -= 1
			emit_signal("RequestCursorAnim", "ArrowBumpLeft")
		if Input.is_action_just_pressed("right1"):
			character_index += 1
			emit_signal("RequestCursorAnim", "ArrowRightBump")
		if Input.is_action_just_pressed("attack1"):
			selection_finished.emit()
			confirmSprite.visible = true
			


func localMultiplayerPlayCursorAnim(anim):
	var animplayer = cursorarrows.get_node("AnimationPlayer")
	if animplayer.is_playing():
		animplayer.stop()
		animplayer.play(anim)
	else:
		animplayer.play(anim)

func set_active(p_active: bool):
	active = p_active
	reference_rect.visible = active


func set_character_index(p_index: int):
	character_index = p_index
	if character_index < 0:
		character_index = Lists.characters.size() - 1
	if character_index >= Lists.characters.size():
		character_index = 0
	set_character(Lists.characters[character_index])


func set_character(p_character: String):
	character = p_character
	character_selected.text = "Character:\n" + GameData.get_character_info(character).display_name
	pixelate.stop()
	pixelate.play("pixelate")
	print(p_character)
	await get_tree().create_timer(0.4).timeout
	var character_info: CharacterInfo = GameData.get_character_info(character)
	character_portrait.texture = load(character_info.portrait_path)
