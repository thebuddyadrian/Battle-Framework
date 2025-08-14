extends CanvasLayer

@onready var lifebar: TextureProgressBar = $Lifebar
@onready var icon: Sprite2D = $Lifebar/Icon
@onready var stock_label: Label = $StockLabel
@onready var pause_menu: Control = $Pause
@onready var player_id_label: Label = $PlayerIDLabel

var player_tracking: BattleCharacter


func track_player(player: BattleCharacter):
	if player.char_name == "sonic":
		icon.texture = preload("res://characters/sonic/sprites/SonicLife.png")
	if player.char_name == "tails":
		icon.texture = preload("res://characters/tails/sprites/TailsLife.png")
	if player.char_name == "shadow":
		icon.texture = preload("res://characters/shadow/sprites/ShadowLife.png")
	if player.char_name == "knuckles":
		icon.texture = preload("res://characters/knuckles/sprites/KnucklesLife.png")
	if player.char_name == "kid_goku":
		icon.texture = preload("res://characters/kid_goku/sprites/KidGokuLife.png")
	lifebar.max_value = player.HP
	player_tracking = player
	pause_menu.player_id = player.player_id
	player_id_label.text = "P" + str(player.player_id)


func _process(delta):
	if player_tracking:
		lifebar.value = player_tracking.current_hp
	stock_label.text = str(player_tracking.current_stocks)
