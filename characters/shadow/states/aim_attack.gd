extends BaseAttack


func _enter(data={}):
	super._enter(data)
	root.velocity.x = 0
	root.velocity.z = 0
	root.velocity.y = -20
