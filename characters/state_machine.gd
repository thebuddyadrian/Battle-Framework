class_name StateMachine
extends Node

var char:BattleCharacter:
	set(val):
		char = val
		for s in states:
			if(states[s] != null):
				states[s].char = val
var current_state:State
var states = {}
enum Special {SHOT, POWER, TRAP}
var ground_special
var aerial_special
var defend_special

@export var Controlset = MoonCastControlSettings.new()


func _ready() -> void:
	for i in get_children():
		states[i.name] = i
	for s in states:
		if(states[s] != null):
			states[s].machine = self
	current_state = states["Idle"]

func think(delta):
	current_state.think(delta)

func goto(new_state_id):
	current_state.exit()
	current_state = states[new_state_id]
	current_state.enter()



func setcontrols() -> void:
	match owner.PLAYER:
		1:
			Controlset = load("res://players/player1controls.tres")
		2:
			Controlset = load("res://players/player2controls.tres")
		3:
			Controlset = load("res://players/player2controls.tres")
		4:
			Controlset = load("res://players/player2controls.tres")
