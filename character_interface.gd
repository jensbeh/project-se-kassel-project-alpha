extends Control


func _ready():
	# stat values
	find_node("Inventory").get_child(0).find_node("Button").visible = false


# Close the inventory
func _on_Button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			Utils.get_scene_manager().get_child(3).get_node("CharacterInterface").queue_free()
			Utils.get_current_player().set_player_can_interact(true)
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			PlayerData.save_inventory()
