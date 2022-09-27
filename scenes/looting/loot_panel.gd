extends Control

signal looted(loot_dict)

var loot_dict = {}
var loot_type
var loot_count
var max_loot = 6

# todos
# animate pickup and loot drop --
# random spawn from treasures, mushrooms --

# setup the looting panel
func _ready():
	Utils.get_current_player().player_collect_loot()
	get_node("Border/Background/VBoxContainer/HBoxContainer/Close").set_text(tr("CLOSE"))
	get_node("Border/Background/VBoxContainer/HBoxContainer/LootAll").set_text(tr("LootAll"))


# generate loot
func loot():
	LootSelector()
	PopulatePanel()


# reopen generated loot
func set_up_content(content):
	loot_dict = content
	PopulatePanel()


# specify the looting table
func set_loot_type(type, dungeon: bool):
	loot_type = type
	if "Boss" in loot_type or "Treasure" in loot_type:
		max_loot = 6
	elif dungeon:
		max_loot = 5
	else:
		max_loot = 2


# randomize the loot with drop chance
func LootSelector():
	for i in range(1, max_loot + 1):
		randomize()
		var loot_selector = (randi() % 100) + 1
		if loot_selector <= GameData.loot_data[loot_type]["Item" + str(i) + "Chance"]:
			var loot = []
			loot.append(GameData.loot_data[loot_type]["Item" + str(i) + "ID"])
			randomize()
			loot.append(int(rand_range(float(GameData.loot_data[loot_type]["Item" + str(i) + "MinQ"]), float(GameData.loot_data[loot_type]["Item" + str(i) + "MaxQ"]))))
			loot_dict[loot_dict.size() + 1] = loot


# add drops to the looting panel
func PopulatePanel():
	var counter = 1
	for i in get_tree().get_nodes_in_group("LootPanelSlots"):
		if counter <= loot_dict.size():
			if str(loot_dict[counter][0]) in ["Jewel", "Potion", "Weapon"]:
				randomize()
				if loot_dict[counter][0] == "Jewel":
					loot_dict[counter][0] = GameData.jewel_IDs[randi() % 4]
				elif loot_dict[counter][0] == "Potion":
					loot_dict[counter][0] = GameData.potion_IDs[randi() % 4]
					if loot_type == "Treasure":
						loot_dict[counter][0] = GameData.potion_IDs[(randi() % 2) + 4]
				elif loot_dict[counter][0] == "Weapon":
					loot_dict[counter][0] = GameData.weapon_IDs[randi() % 4]
			get_node(str(i.get_path()) + "/Name").set_text(tr(str(GameData.item_data[str(loot_dict[counter][0])]["Name"])))
			var texture = GameData.item_data[str(loot_dict[counter][0])]["Texture"]
			var frame = int(GameData.item_data[str(loot_dict[counter][0])]["Frame"])
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
			slot.frame = frame
			if loot_dict[counter][1] > 1:
				get_node(str(i.get_path()) + "/LootIcon/TextureRect").show()
				get_node(str(i.get_path()) + "/LootIcon/TextureRect/Stack").set_text(str(loot_dict[counter][1]))
			counter += 1


# looting with click on item
func _on_Icon_gui_input(event, lootpanelslot):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if loot_dict.has(lootpanelslot):
				loot_item(lootpanelslot)


# close the loot panel
func _on_Close_pressed():
	get_parent().remove_child(self)
	queue_free()
	emit_signal("looted", loot_dict)
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().player_looted()


# loot all items and close the panel
func _on_LootAll_pressed():
	var size = loot_dict.size()
	get_parent().remove_child(self)
	queue_free()
	for i in range(1,size + 1):
		loot_item(i)
	emit_signal("looted", loot_dict)
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().player_looted()


func loot_item(item_idx):
	# gold
	if loot_dict[item_idx][0] == 10064:
		Utils.get_current_player().set_gold(Utils.get_current_player().get_gold() + loot_dict[item_idx][1])
	# items
	else:
		if GameData.item_data[str(loot_dict[item_idx][0])]["Stackable"]:
			var stored = false
			for i in range(1,31):
				var slot = "Inv" + str(i)
				if PlayerData.inv_data[slot]["Item"] == loot_dict[item_idx][0]:
					PlayerData.inv_data[slot]["Stack"] += loot_dict[item_idx][1]
					stored = true
					break
			if !stored:
				for i in range(1,31):
					var slot = "Inv" + str(i)
					if PlayerData.inv_data[slot]["Item"] == null:
						PlayerData.inv_data[slot]["Item"] = loot_dict[item_idx][0]
						PlayerData.inv_data[slot]["Stack"] = loot_dict[item_idx][1]
						break
		else:
			for i in range(1,31):
				var slot = "Inv" + str(i)
				if PlayerData.inv_data[slot]["Item"] == null:
					PlayerData.inv_data[slot]["Item"] = loot_dict[item_idx][0]
					PlayerData.inv_data[slot]["Stack"] = loot_dict[item_idx][1]
					break
	# remove from looting panel
	loot_dict.erase(item_idx)
	var loot_slot = "Border/Background/VBoxContainer/Lootslots/VBoxContainer/Loot" + str(item_idx)
	get_node(loot_slot + "/LootIcon/Icon/Sprite").texture = null
	get_node(loot_slot + "/LootIcon/TextureRect").hide()
	get_node(loot_slot + "/LootIcon/TextureRect/Stack").set_text("")
	get_node(loot_slot + "/Name").set_text("")
