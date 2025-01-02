extends Control

# If there's a player selecting a character using this node
var active: bool = false: set = set_active
var character_index: int = 0 : set = set_character_index
var character: String : set = set_character
@export var player_number: int = 1
@onready var character_selected: Label = $CharacterSelected
@onready var reference_rect: ReferenceRect = $ReferenceRect
@onready var player_name: Label = $PlayerName

signal selection_finished


func _ready() -> void:
	player_name.text = "Player " + str(player_number)
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
		character_index = CharacterList.characters.size() - 1
	if character_index >= CharacterList.characters.size():
		character_index = 0
	set_character(CharacterList.characters[character_index])


func set_character(p_character: String):
	character = p_character
	character_selected.text = "Character:\n" + CharacterList.character_display_names[character]
