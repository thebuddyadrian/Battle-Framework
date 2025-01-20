extends BaseState
# Example state machine script to show you how the state machine should be used

# Called at the beginning of the state.
func _enter(data = {}):
#	Can be used to play an animation on the player as soon as the state begins
# 	Use the "root" variable to call functions on the player
#	root.animplayer.play("Idle")
	pass
	

# Called every frame of the state
func _step():
#	This is where you can handle changing to other states, like by pressing a button
#	if root.input("attack", "just_pressed")):
#		parent.change_state("Punch1")
	pass

# Called when leaving the state and changing to another one.
func _exit(next_state):
	super._exit(next_state)
