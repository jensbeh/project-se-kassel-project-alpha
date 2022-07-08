extends Control

var inv_slot = preload("res://scenes/inventory/InventorySlot.tscn")

onready var gridcontainer = get_node("Background/MarginContainer/VBox/ScrollContainer/GridContainer")


func _ready():
	for i in PlayerData.inv_data.keys():
		var inv_slot_new = inv_slot.instance()
		if PlayerData.inv_data[i]["Item"] != null:
			var item_name = GameData.item_data[str(PlayerData.inv_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Assets/Icon_Items/" + item_name + ".png")
			inv_slot_new.get_node("Icon").set_texture(icon_texture)
		gridcontainer.add_child(inv_slot_new, true)


func _on_Button_pressed():
	Utils.get_scene_manager().get_node("TradeInventory").queue_free()
	Utils.get_current_player().set_player_can_interact(true)
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().set_movment_animation(true)
	Utils.get_scene_manager().find_node("Inventory").visible = false
	# reset npc interaction state
	for npc in Utils.get_scene_manager().get_child(0).get_child(0).find_node("npclayer").get_children():
		npc.set_interacted(false)
