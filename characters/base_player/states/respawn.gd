extends BaseState


func _enter(data = {}):
	parent.make_timer("_do_respawn", 60, self)
	root.hurtbox.active = false
	root.visible = false
	root.invincibility_frames = 210
	root.current_stocks -= 1


func _do_respawn():
	if root.current_stocks == 0:
		root.kod.emit(root)
		return
	root.current_hp = root.max_hp
	change_state("Idle")


func _exit(next_state):
	root.visible = true
	root.hurtbox.active = true
