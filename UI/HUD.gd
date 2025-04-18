extends CanvasLayer

@onready var HPBar = $HP
@onready var MPBar = $Mana


func _ready() -> void:
	if Globals.CLIENTSIDE_PLAYER != null:
		HPBar.max_value = Globals.CLIENTSIDE_PLAYER.HP
		MPBar.max_value = Globals.CLIENTSIDE_PLAYER.MP
		
		HPBar.min_value = 0
		MPBar.min_value = 0

func _physics_process(delta: float) -> void:
	if Globals.CLIENTSIDE_PLAYER != null:
		HPBar.value = Globals.CLIENTSIDE_PLAYER.HP
		MPBar.value = Globals.CLIENTSIDE_PLAYER.MP
