extends Control

@onready var ImagePreview = $CenterContainer/TextureRect
@onready var StageNameTag = $Label
@onready var SelectedStageList = $ScrollContainer/VBoxContainer

var stages
var stage_step : int = 0
var max_selected_stages : int = 5
var selected_stages = []

func _ready() -> void:
	stages = GameData.battle_stages

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("right1"):
		stage_step += 1
		if stage_step >= stages.size():
			stage_step = 0
		Update_UI_Visuals(stages[stage_step], null)
		
	if Input.is_action_just_pressed("left1"):
		stage_step -= 1
		if stage_step <= 0:
			stage_step = stages.size() - 1
		Update_UI_Visuals(stages[stage_step], null)
		
	if Input.is_action_just_pressed("attack1"):
		if selected_stages.size() < max_selected_stages:
			selected_stages.append(stages[stage_step])
			var new_nametag = Label.new()
			new_nametag.text = stages[stage_step]
			SelectedStageList.add_child(new_nametag)
		else:
			print("maximum number of stages selected!")

func Update_UI_Visuals(nametag : String, stage_image):
	#for now, i'm skipping the image
	StageNameTag.text = nametag
	if stage_image != null:
		ImagePreview.texture = stage_image
