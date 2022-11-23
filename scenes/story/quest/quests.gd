extends NinePatchRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_QuestSlot_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			Utils.get_player_ui().set_quest(get_name().to_upper())
			for quest in get_parent().get_children():
				quest.get_node("locked").show()
