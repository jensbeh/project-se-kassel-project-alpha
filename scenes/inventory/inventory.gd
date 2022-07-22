extends Control

var inv_slot = load(Constants.INV_SLOT)

onready var gridcontainer = get_node("Background/MarginContainer/VBox/ScrollContainer/GridContainer")

# Load player inventory
func _ready():
	for i in PlayerData.inv_data.keys():
		var inv_slot_new = inv_slot.instance()
		if i != "Item" and i != "Stack":
			if PlayerData.inv_data[i]["Item"] != null:
				var item_name = GameData.item_data[str(PlayerData.inv_data[i]["Item"])]["Name"]
				var icon_texture = load("res://Assets/Icon_Items/" + item_name + ".png")
				inv_slot_new.get_node("Icon").set_texture(icon_texture)
				var item_stack = PlayerData.inv_data[i]["Stack"]
				if item_stack != null and item_stack > 1:
					inv_slot_new.get_node("TextureRect/Stack").set_text(str(item_stack))
					inv_slot_new.get_node("TextureRect").visible = true
			gridcontainer.add_child(inv_slot_new, true)
	gridcontainer.remove_child(gridcontainer.get_child(gridcontainer.get_child_count()-1))
	# Sets the name and the gold from the player
	$Background/MarginContainer/VBox/TitleBox/Title/Titlename.text = tr("INVENTORY")
	$Background/MarginContainer/VBox/TitleBox/Control/Gold.text = "Gold: " + Utils.get_current_player().get_gold()


# Close the inventory
func _on_Button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if Utils.get_scene_manager().get_child(3).get_node_or_null("TradeInventory") != null:
				Utils.get_scene_manager().get_child(3).get_node("TradeInventory").queue_free()
				Utils.get_current_player().set_player_can_interact(true)
				Utils.get_current_player().set_movement(true)
				Utils.get_current_player().set_movment_animation(true)
				# Reset npc interaction state
				for npc in Utils.get_scene_manager().get_child(0).get_child(0).find_node("npclayer").get_children():
					npc.set_interacted(false)
			else:
				Utils.get_scene_manager().get_child(3).get_node("Inventory").queue_free()
			PlayerData.save_inventory()
