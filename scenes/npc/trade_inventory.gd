extends Control

var inv_slot = preload("res://scenes/inventory/TradeInventorySlot.tscn")

onready var gridcontainer = get_node("ColorRect/MarginContainer/HBoxContainer/Background/MarginContainer/VBox/ScrollContainer/GridContainer")


func _ready():
	for i in PlayerData.inv_data.keys():
		var inv_slot_new = inv_slot.instance()
		if MerchantData.inv_data[i]["Item"] != null:
			var item_name = GameData.item_data[str(MerchantData.inv_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Assets/Icon_Items/" + item_name + ".png")
			inv_slot_new.get_node("Icon").set_texture(icon_texture)
		gridcontainer.add_child(inv_slot_new, true)
	
	find_node("Inventory").get_child(0).find_node("Button").visible = false


# Close trade inventory
func _on_Button_pressed():
	Utils.get_scene_manager().get_child(3).get_node("TradeInventory").queue_free()
	Utils.get_current_player().set_player_can_interact(true)
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().set_movment_animation(true)
	# Reset npc interaction state
	for npc in Utils.get_scene_manager().get_child(0).get_child(0).find_node("npclayer").get_children():
		npc.set_interacted(false)


# Sets the correct name of the npc
func set_name(npc_name):
	if npc_name == "sam":
		npc_name = "Sam"
	elif npc_name == "lea":
		npc_name = "Lea"
	elif npc_name == "heinz":
		npc_name = "Heinz"
	else:
		npc_name = "Bella"
	$ColorRect/MarginContainer/HBoxContainer/Background.find_node("Titlename").text = npc_name + "´s " + tr("INVENTORY")
