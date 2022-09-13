extends Control

var loot_dict = {}

func _ready():
	pass # Replace with function body.

#4h
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

