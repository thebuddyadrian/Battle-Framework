extends CanvasLayer

@onready var lifebar: TextureProgressBar = $Lifebar
@onready var icon: Sprite2D = $Lifebar/Icon
@onready var stock_label: Label = $StockLabel

var player_tracking: BattleCharacter


func track_player(player: BattleCharacter):
	if player.char_name == "sonic":
		icon.texture = preload("res://assets/ui/SonicLife.png")
	if player.char_name == "tails":
		icon.texture = preload("res://assets/ui/TailsLife.png")
	if player.char_name == "shadow":
		icon.texture = preload("res://assets/ui/ShadowLife.png")
	if player.char_name == "knuckles":
		icon.texture = preload("res://assets/ui/KnucklesLife.png")
	if player.char_name == "kid_goku":
		icon.texture = preload("res://assets/ui/KidGokuLife.png")
	lifebar.max_value = player.HP
	player_tracking = player


func _process(delta):
	if player_tracking:
		lifebar.value = player_tracking.current_hp
	stock_label.text = str(player_tracking.current_stocks)
