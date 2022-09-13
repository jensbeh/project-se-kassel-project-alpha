extends Control
# 11,5h
var loot_dict = {}
var loot_type
var loot_count
var max_loot = 6

# todos
# pickup and animtate ore, leafes and other loots --
# disappear the completely lootet symbols and items --
# random spawn from treasures in dungeons and ores and leafs etc --

# setup the looting panel
func _ready():
	get_node("Border/Background/VBoxContainer/HBoxContainer/Close").set_text(tr("LOOTALL"))
	get_node("Border/Background/VBoxContainer/HBoxContainer/LootAll").set_text(tr("CLOSE"))
	LootSelector()
	PopulatePanel()


# specify the looting table
func set_loot_type(type, dungeon: bool):
	loot_type = type
	if dungeon:
		max_loot = 6
	else:
		max_loot = 3


# randomize the loot with drop chance
func LootSelector():
	for i in range(1, max_loot + 1):
		randomize()
		var loot_selector = randi() % 100 + 1
		if loot_selector <= GameData.loot_data[loot_type]["Item" + str(i) + "Chance"]:
			var loot = []
			loot.append(GameData.loot_data[loot_type]["Item" + str(i) + "ID"])
			randomize()
			loot.append(int(rand_range(float(GameData.loot_data[loot_type]["Item" + str(i) + "MinQ"]), float(GameData.loot_data[loot_type]["Item" + str(i) + "MaxQ"]))))
			loot_dict[loot_dict.size() + 1] = loot
	

# add drops to the looting panel
func PopulatePanel():
	var counter = loot_dict.size()
	for i in get_tree().get_nodes_in_group("LootPanelSlots"):
		if counter != 0:
			if str(loot_dict[counter][0]) in ["jewel", "potion", "weapon"]:
				randomize()
				if loot_dict[counter][0] == "jewel":
					loot_dict[counter][0] = GameData.jewel_IDs[randi() %+ 4]
				elif loot_dict[counter][0] == "potion":
					loot_dict[counter][0] = GameData.potion_IDs[randi() % 5]
				elif loot_dict[counter][0] == "weapon":
					loot_dict[counter][0] = GameData.weapon_IDs[randi() % 4]
			get_node(str(i.get_path()) + "/Label").set_text(loot_dict[counter][0])
			var texture = GameData.item_data[str(loot_dict[counter][0])]["Texture"]
			var frame = GameData.item_data[str(loot_dict[counter][0])]["Frame"]
			var icon = load("res://Assets/Icon_Items/" + texture + ".png")
			var slot = get_node(str(i.get_path()) + "/LootIcon/Icon/Sprite")
			if texture == "item_icons_1":
				slot.set_scale(Vector2(2.5,2.5))
				slot.set_hframes(16)
				slot.set_vframes(27)
			else:
				slot.set_scale(Vector2(4.5,4.5))
				slot.set_hframes(13)
				slot.set_vframes(15)
			slot.set_texture(icon)
			slot.set_frame = frame
			if loot_dict[counter][1] > 1:
				get_node(str(i.get_path()) + "/LootIcon/TextureRect/Stack").set_text(str(loot_dict[counter][1]))
			counter -= 1


# looting with click on item
func _on_Icon_gui_input(event, lootpanelslot):
	if event.is_pressed():
		if loot_dict.has(lootpanelslot):
			loot_item(lootpanelslot)


# close the loot panel
func _on_Close_pressed():
	Utils.get_ui().get_node("LootPanel").queue_free()
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().set_movment_animation(true)


func _on_LootAll_pressed():
	for i in range(1,7):
		loot_item(i)
	Utils.get_ui().get_node("LootPanel").queue_free()
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().set_movment_animation(true)


func loot_item(item_idx):
	# gold
	if loot_dict[item_idx][0] == 10064:
		Utils.get_current_player().set_gold(Utils.get_current_player().get_gold() + loot_dict[item_idx][1])
	# items
	else:
		if GameData.item_data[str(loot_dict[item_idx][0])]["Stackable"]:
			for i in range(1,31):
				if PlayerData.inv_data["Inv" + str(i)]["Item"] == loot_dict[item_idx][0]:
					PlayerData.inv_data["Inv" + str(i)]["Stack"] += loot_dict[item_idx][1]
		else:
			for i in range(1,31):
				if PlayerData.inv_data["Inv" + str(i)]["Item"] == null:
					PlayerData.inv_data["Inv" + str(i)]["Item"] = loot_dict[item_idx][0]
					PlayerData.inv_data["Inv" + str(i)]["Stack"] = loot_dict[item_idx][1]
	# remove from looting panel
	loot_dict.erase(item_idx)
	var loot_slot = "Border/Background/VBoxContainer/Lootslots/VBoxContainer" + str(item_idx)
	get_node(loot_slot + "/LootIcon/Icon/Sprite").texture = null
	get_node(loot_slot + "LootIcon/TextureRect/Stack").set_text("")
	get_node(loot_slot + "Name").set_text("")
