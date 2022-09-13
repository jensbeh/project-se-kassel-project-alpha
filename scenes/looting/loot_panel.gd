extends Control
#4h + 2h + 2h
var loot_dict = {}
var mob_type
var loot_count
# mob_type can be treasure, boss or mob1-3 with diffrent loots
# show loot symbol and interacting with "e" for open loot panel
# pickup and animtate ore, leafes and other loots
# disappear the completely lootet symbols and items
# random spawn from treasures in dungeons and ores and leafs etc

func _ready():
	get_node("Border/Background/VBoxContainer/HBoxContainer/Close").set_text(tr("LOOTALL"))
	get_node("Border/Background/VBoxContainer/HBoxContainer/LootAll").set_text(tr("CLOSE"))
	LootSelector()
	PopulatePanel()


func LootSelector():
	for i in range(1, 7):
		randomize()
		var loot_selector = randi() % 100 + 1
		if loot_selector <= GameData.loot_data[mob_type]["Item" + str(i) + "Chance"]:
			var loot = []
			loot.append(GameData.loot_data[mob_type]["Item" + str(i) + "ID"])
			randomize()
			loot.append(int(rand_range(float(GameData.loot_data[mob_type]["Item" + str(i) + "MinQ"]), float(GameData.loot_data[mob_type]["Item" + str(i) + "MaxQ"]))))
			loot_dict[loot_dict.size() + 1] = loot
	

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


func _on_Icon_gui_input(event, lootpanelslot):
	if event.is_pressed():
		if loot_dict.has(lootpanelslot):
			if loot_dict[lootpanelslot][0] == "Gold":
				Utils.get_current_player().set_gold(Utils.get_current_player().get_gold() + loot_dict[lootpanelslot][1])
				loot_dict.erase(lootpanelslot)
				var loot_slot = "Border/Background/VBoxContainer/Lootslots/VBoxContainer" + str(lootpanelslot)
				get_node(loot_slot + "/LootIcon/Icon/Sprite").texture = null
				get_node(loot_slot + "LootIcon/TextureRect/Stack").set_text("")
				get_node(loot_slot + "Name").set_text("")
	pass

