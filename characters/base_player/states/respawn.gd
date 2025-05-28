extends BaseState


func _enter(data = {}):
	parent.make_timer("_do_respawn", 60, self)
	root.hurtbox.active = false
	root.visible = false


func _do_respawn():
	root.current_hp = root.HP
	change_state("Idle")


func _exit(next_state):
	root.visible = true
	root.hurtbox.active = true
