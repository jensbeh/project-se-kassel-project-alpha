extends Control

var inv_slot = Constants.PreloadedScenes.TradeInvSlotScene

onready var gridcontainer = $ColorRect/MarginContainer/HBoxContainer/Background/MarginContainer/VBox/ScrollContainer/TradeGridContainer
onready var npcNameNode = $ColorRect/MarginContainer/HBoxContainer/Background/MarginContainer/VBox/TitleBox/Title/Titlename
onready var inventoryNode = $ColorRect/MarginContainer/HBoxContainer/Inventory

func _ready():
	for i in range(1,MerchantData.inv_data.size()+1):
		var inv_slot_new = inv_slot.instance()
		var slot = "Inv" + str(i)
		if MerchantData.inv_data[slot]["Item"] != null:
			if (MerchantData.inv_data[slot]["Time"] == null or 
			(MerchantData.inv_data[slot]["Time"] + (3* DayNightCycle.COMPLETE_DAY_TIME)) > 
			(DayNightCycle.get_passed_days_since_start() * DayNightCycle.COMPLETE_DAY_TIME + DayNightCycle.get_current_time())):
				var texture = GameData.item_data[str(MerchantData.inv_data[slot]["Item"])]["Texture"]
				var frame = GameData.item_data[str(MerchantData.inv_data[slot]["Item"])]["Frame"]
				var icon_texture = load("res://assets/icon_items/" + texture + ".png")
				if texture == "item_icons_1":
					inv_slot_new.get_node("Icon/Sprite").set_scale(Vector2(1.5,1.5))
					inv_slot_new.get_node("Icon/Sprite").set_hframes(16)
					inv_slot_new.get_node("Icon/Sprite").set_vframes(27)
				else:
					inv_slot_new.get_node("Icon/Sprite").set_scale(Vector2(2.5,2.5))
					inv_slot_new.get_node("Icon/Sprite").set_hframes(13)
					inv_slot_new.get_node("Icon/Sprite").set_vframes(15)
				inv_slot_new.get_node("Icon/Sprite").set_texture(icon_texture)
				inv_slot_new.get_node("Icon/Sprite").frame = frame
				
				var item_stack = MerchantData.inv_data[slot]["Stack"]
				if item_stack != null and item_stack > 1:
					inv_slot_new.get_node("TextureRect/Stack").set_text(str(item_stack))
					inv_slot_new.get_node("TextureRect").visible = true
			else:
				MerchantData.inv_data[slot]["Item"] = null
				MerchantData.inv_data[slot]["Stack"] = null
				MerchantData.inv_data[slot]["Time"] = null
		gridcontainer.add_child(inv_slot_new, true)
	check_slots()
	inventoryNode.get_child(0).find_node("Deletebox").visible = false


# Close trade inventory
func _on_Button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			# Sound
			Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI)
			Utils.get_trade_inventory().queue_free()
			Utils.get_current_player().set_player_can_interact(true)
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			# Reset npc interaction state
			for npc in Utils.get_scene_manager().get_child(0).get_child(0).find_node("npclayer").get_children():
				npc.set_interacted(false)
			MerchantData.save_merchant_inventory()
			Utils.save_game(true)


# Sets the correct name of the npc
func set_name(npc_name):
	if npc_name == "sam":
		npc_name = "Sam"
	elif npc_name == "lea":
		npc_name = "Lea"
	elif npc_name == "heinz":
		npc_name = "Heinz"
	elif npc_name == "haley":
		npc_name = "Haley"
	else:
		npc_name = "Bella"
	npcNameNode.text = npc_name + "´s " + tr("INVENTORY")
	
func check_slots():
	var free = false
	var free2 = false
	var trade = gridcontainer
	var slots = MerchantData.inv_data.size()
	for i in MerchantData.inv_data:
		if MerchantData.inv_data[i]["Item"] == null:
			free = true
	if !free:
		Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI2)
		for i in range(slots+1,slots +7):
			var inv_slot_new = inv_slot.instance()
			MerchantData.inv_data["Inv" + str(i)] = {"Item":null,"Stack":null, "Time":null}
			trade.add_child(inv_slot_new,true)
		MerchantData.save_merchant_inventory()
	elif slots > 30:
		for i in range(0,6):
			if MerchantData.inv_data["Inv" + str(MerchantData.inv_data.size() - i)]["Item"] != null:
				free2 = true
		if !free2:
			Utils.get_and_play_sound(Constants.PreloadedSounds.OpenUI2)
			slots = MerchantData.inv_data.size()
			for i in range(0,6):
				MerchantData.inv_data.erase("Inv" + str(slots - i))
				trade.get_node("Inv" + str(slots - i)).queue_free()
			check_slots()


func get_trade_gridcontainer():
	return gridcontainer


func get_sound_player():
	return get_node("Sound")
