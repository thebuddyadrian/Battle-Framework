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
@export var portrait_texture : Dictionary = {
	"sonic": preload("res://characters/sonic/sprites/Sonic Portrait.png"),
	"tails": preload("res://characters/tails/sprites/Tails Portrait.png"),
	"knuckles": preload("res://characters/knuckles/sprites/Knuckles Portrait.png"),
	"shadow": preload("res://characters/shadow/sprites/Shadow Portrait.png")
	}


signal selection_finished


func _ready() -> void:
	#player_name.text = "Player " + str(player_number)
	set_active(active)
	set_character_index(character_index)
	


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
	if character_index < 0:
		character_index = Lists.characters.size() - 1
	if character_index >= Lists.characters.size():
		character_index = 0
	set_character(Lists.characters[character_index])


func set_character(p_character: String):
	character = p_character
	character_selected.text = "Character:\n" + Lists.character_display_names[character]
	pixelate.play("pixelate")
	await get_tree().create_timer(0.4).timeout
	character_portrait.texture = portrait_texture[character]
