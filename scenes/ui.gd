extends CanvasLayer


func _ready():
	pass # Replace with function body.

func in_world(value):
	if value:
		get_node("ControlNotes").in_world(value)
		get_node("PlayerUI").visible = value
	else:
		get_node("ControlNotes").in_world(value)
		get_node("PlayerUI").visible = value
