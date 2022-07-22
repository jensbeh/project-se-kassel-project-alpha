extends Control


func _ready():
	# load weapon
	if PlayerData.equipment_data["Item"] != null:
		var weapon = find_node("WeaponBox")
		var item_name = GameData.item_data[str(PlayerData.equipment_data["Item"])]["Name"]
		var icon_texture = load("res://Assets/Icon_Items/" + item_name + ".png")
		weapon.get_node("Icon").set_texture(icon_texture)
	# stat values
	find_node("Inventory").get_child(0).find_node("Button").visible = false
	find_node("Health").set_text(tr("HEALTH") + ": " + str(Utils.get_current_player().get_max_health()))
	find_node("Damage").set_text(tr("ATTACK") + ": " + str(Utils.get_current_player().get_attack()))

# Close the inventory
func _on_Button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			Utils.get_scene_manager().get_child(3).get_node("CharacterInterface").queue_free()
			Utils.get_current_player().set_player_can_interact(true)
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			PlayerData.inv_data["Weapon"] = PlayerData.equipment_data
			PlayerData.save_inventory()
