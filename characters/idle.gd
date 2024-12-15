extends State


@onready var ControlSet = $"../".Controlset

func enter():
	pass
func _physics_process(delta: float):#, inputs):
	if(ControlSet.action_jump):
		#machine.goto("Jump")
		return
	if(ControlSet.direction_left or ControlSet.direction_right or ControlSet.direction_up or ControlSet.direction_down):
		#machine.goto("Run")
		print_debug("Ayo?!")
		return #ALWAYS use return after calling goto
func exit():
	pass
