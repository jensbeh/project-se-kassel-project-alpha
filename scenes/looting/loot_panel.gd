extends Control

signal looted(loot_dict)

var loot_dict = {}
var loot_type
var loot_count
var max_loot = 6
var all = false
var keys

# setup the looting panel
func _ready():
	Utils.get_current_player().player_collect_loot()
	get_node("Border/Background/VBoxContainer/HBoxContainer/Close").set_text(tr("CLOSE_PANEL"))
	get_node("Border/Background/VBoxContainer/HBoxContainer/LootAll").set_text(tr("LOOTALL"))


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
	if dungeon:
		max_loot = GameData.loot_data[loot_type]["ItemCountMax"]
	elif "Treasure" in type:
		max_loot = 6
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
	var num = 1
	keys = loot_dict.keys()
	for i in get_tree().get_nodes_in_group("LootPanelSlots"):
		if num <= loot_dict.size():
			var counter = keys[num -1]
			if str(loot_dict[counter][0]) in ["Jewel", "Potion", "Weapon"]:
				randomize()
				if loot_dict[counter][0] == "Jewel":
					var jewel = GameData.jewel_IDs[randi() % 4]
					var found = false
					for idx in loot_dict:
						var item = loot_dict[idx]
						if str(item[0]) == str(jewel):
							item[1] += 1
							found = true
							loot_dict.erase(counter)
							counter = idx
							break
					if !found:
						loot_dict[counter][0] = jewel
				elif loot_dict[counter][0] == "Potion":
					loot_dict[counter][0] = GameData.potion_IDs[randi() % 5]
					if loot_type == "Treasure":
						loot_dict[counter][0] = GameData.potion_IDs[(randi() % 3) + 5]
				elif loot_dict[counter][0] == "Weapon":
					loot_dict[counter][0] = GameData.weapon_IDs[randi() % 4]
			num += 1
		else:
			i.hide()
	setup()


func setup():
	var num = 1
	for i in get_tree().get_nodes_in_group("LootPanelSlots"):
		if num <= loot_dict.size():
			var counter = keys[num -1]
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
			num += 1
			i.show()
		else:
			i.hide()


# looting with click on item
func _on_Icon_gui_input(event, lootpanelslot):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var item_idx
			if keys.size() < lootpanelslot:
				item_idx = keys[-1]
			else:
				item_idx = keys[lootpanelslot -1]
			if loot_dict.has(item_idx):
				if loot_dict[item_idx][0] == 10064:
					Utils.set_and_play_sound(Constants.PreloadedSounds.Collect)
				else:
					Utils.set_and_play_sound(Constants.PreloadedSounds.Collect2)
				loot_item(item_idx)


# close the loot panel
func _on_Close_pressed():
	Utils.get_current_player().get_node("Sound").stream = Constants.PreloadedSounds.OpenUI
	Utils.get_current_player().get_node("Sound").play()
	Utils.get_current_player().player_looted()
	Utils.save_game(true)
	get_parent().remove_child(self)
	queue_free()
	emit_signal("looted", loot_dict)


# loot all items and close the panel
func _on_LootAll_pressed():
	Utils.get_current_player().player_looted()
	all = true
	var key = loot_dict.keys()
	var size = loot_dict.size()
	if size > 1:
		Utils.set_and_play_sound(Constants.PreloadedSounds.Collect2)
	else:
		Utils.set_and_play_sound(Constants.PreloadedSounds.Collect)
	get_parent().remove_child(self)
	queue_free()
	Utils.save_game(true)
	for i in range(1,size + 1):
		loot_item(key[i -1])
	emit_signal("looted", loot_dict)


func loot_item(item_idx):
	var looted = false
	# gold
	if loot_dict[item_idx][0] == 10064:
		Utils.get_current_player().set_gold(Utils.get_current_player().get_gold() + loot_dict[item_idx][1])
		looted = true
	# items
	else:
		if GameData.item_data[str(loot_dict[item_idx][0])]["Stackable"]:
			var stored = false
			for i in range(1,31):
				var slot = "Inv" + str(i)
				if PlayerData.inv_data[slot]["Item"] == loot_dict[item_idx][0] and PlayerData.inv_data[slot]["Stack"] + loot_dict[item_idx][1] <= Constants.MAX_STACK_SIZE:
					PlayerData.inv_data[slot]["Stack"] += loot_dict[item_idx][1]
					stored = true
					looted = true
					break
			if !stored:
				for i in range(1,31):
					var slot = "Inv" + str(i)
					if PlayerData.inv_data[slot]["Item"] == null:
						PlayerData.inv_data[slot]["Item"] = loot_dict[item_idx][0]
						PlayerData.inv_data[slot]["Stack"] = loot_dict[item_idx][1]
						looted = true
						break
		else:
			for i in range(1,31):
				var slot = "Inv" + str(i)
				if PlayerData.inv_data[slot]["Item"] == null:
					PlayerData.inv_data[slot]["Item"] = loot_dict[item_idx][0]
					PlayerData.inv_data[slot]["Stack"] = loot_dict[item_idx][1]
					looted = true
					break
	if looted:
		# remove from looting panel
		loot_dict.erase(item_idx)
		var loot_slot = "Border/Background/VBoxContainer/Lootslots/VBoxContainer/Loot" + str(item_idx)
		get_node(loot_slot + "/LootIcon/Icon/Sprite").texture = null
		get_node(loot_slot + "/LootIcon/TextureRect").hide()
		get_node(loot_slot + "/LootIcon/TextureRect/Stack").set_text("")
		get_node(loot_slot + "/Name").set_text("")
		get_node(loot_slot).hide()
		if loot_dict.size() == 0 and !all:
			_on_Close_pressed()
	
	else:
		# Msg can not loot - inventory full
		var msg = load(Constants.FULL_INV_MSG).instance()
		Utils.get_ui().add_child(msg)
