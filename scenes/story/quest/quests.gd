extends NinePatchRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Accept the Quest
func _on_QuestSlot_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			Utils.set_and_play_sound(Constants.PreloadedSounds.Select)
			Utils.get_player_ui().set_quest(get_name().to_upper())
			Utils.get_player_ui().set_quest_finished(false)
			for quest in get_parent().get_children():
				quest.get_node("locked").show()
			Utils.get_ui().get_node("QuestList").show_abort_button()
			Utils.save_game(true)
