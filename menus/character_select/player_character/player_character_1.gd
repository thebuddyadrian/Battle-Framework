extends Control

# If there's a player selecting a character using this node
var active: bool = false: set = set_active
var character: String : set = set_character, get = get_character
@export var player_number: int = 1
@onready var selector_component: Node = $SelectorComponent
@onready var character_selected: Label = $CharacterSelected
@onready var reference_rect: ReferenceRect = $ReferenceRect
@onready var player_name: Label = $PlayerName

signal selection_finished


func _ready() -> void:
	selector_component.items = Lists.characters
	player_name.text = "Player " + str(player_number)
	set_active(active)


func _on_selector_component_selection_changed(selected: int) -> void:
	character_selected.text = "Character:\n" + (Lists.character_display_names.merged(Lists.modded_char_display_names))[character]


func set_active(p_active: bool):
	active = p_active
	selector_component.active = active
	reference_rect.visible = active


func set_character(p_character: String):
	selector_component.selected = selector_component.items.find(p_character)


func get_character() -> String:
	return selector_component.items[selector_component.selected]
