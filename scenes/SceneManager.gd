extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func transition_to_scene(new_scene: String):
	$CurrentScene.get_child(0).queue_free()
	$CurrentScene.add_child(load(new_scene).instance())
