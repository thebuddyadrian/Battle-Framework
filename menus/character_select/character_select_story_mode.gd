extends Control

var story_mode_characters: Array[String] = ["sonic", "knuckles"] 
var character_visual_nodes: Array[Control] = [$Sonic, $Knuckles]
var current_character_index = 0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sonic.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("left1")):
		_set_character_index(current_character_index - 1)
		
		pass
	if (Input.is_action_just_pressed("right1")):
		_set_character_index(current_character_index + 1)
		pass
	pass


func on_character_selected(char_name: String ) -> void:
	MatchSetup.stage_list = ["STORYMAP_3D"]
	MatchSetup.cpu_players = 0
	MatchSetup.human_players = 1
	MatchSetup.single_window = false
	MatchSetup.character_choices = {1:char_name}  
	
	SceneChanger.change_scene_to_file("res://match_scene/match_scene.tscn")

	pass

func _set_character_index(i: int) -> void:
	if( i > 0 && i < story_mode_characters.size() ):
		current_character_index = i
		#character_visual_nodes[current_character_index].focus
		pass
	pass


## signal receivers

func _on_sonic_pressed() -> void:
	on_character_selected("sonic")
	pass # Replace with function body.


func _on_knuckles_pressed() -> void:
	on_character_selected("knuckles")
	pass # Replace with function body.
