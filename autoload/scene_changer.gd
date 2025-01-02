extends CanvasLayer

@onready var black: Panel = $Black

var is_changing_scene: bool = false

func change_scene_to_packed(scene: PackedScene):
	var tween = get_tree().create_tween()
	is_changing_scene = true
	tween.stop()
	tween.tween_property(black, "modulate:a", 1, 0.5)
	tween.play()
	await tween.finished
	get_tree().change_scene_to_packed(scene)
	tween.stop()
	tween.tween_property(black, "modulate:a", 0, 0.5)
	tween.play()


func change_scene_to_file(scene_path: String):
	change_scene_to_packed(load(scene_path))
