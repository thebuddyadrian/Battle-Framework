extends Control

@onready var player_container: GridContainer = $PlayerContainer
var current_player = 1

func _ready() -> void:
	player_container.get_child(0).active = true
	for player in player_container.get_children():
		player.connect("selection_finished", Callable(self, "_on_player_selection_finished"))


func _on_player_selection_finished():
	var current_player_node = player_container.get_child(current_player - 1)
	Game.character_choices[current_player] = current_player_node.character
	current_player_node.active = false
	if current_player == 4:
		get_tree().change_scene_to_file("res://levels/level.tscn")
		return
	current_player += 1
	await get_tree().process_frame
	current_player_node = player_container.get_child(current_player - 1)
	current_player_node.active = true
	print(current_player)
