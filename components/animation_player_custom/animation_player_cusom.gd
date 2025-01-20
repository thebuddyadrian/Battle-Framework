extends AnimationPlayer

@export var segment: String = ""


func get_anim_segment_start(anim_name: StringName, segment: String):
	var animation: Animation = get_animation(anim_name)
	animation.get_property_list()
	
