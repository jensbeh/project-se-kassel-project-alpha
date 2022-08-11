extends Popup

var origin = ""
var slot = ""
var valid = false


func _ready():
	# check origin and if valid
	var item_id
	if origin == "Inventory":
		if PlayerData.inv_data[slot]["Item"] != null:
			item_id = str(PlayerData.inv_data[slot]["Item"])
			valid = true
	elif origin == "CharacterInterface":
		if PlayerData.equipment_data["Item"] != null:
			item_id = str(PlayerData.equipment_data["Item"])
			valid = true
	else:# merchant
		if MerchantData.inv_data[slot]["Item"] != null:
			item_id = str(MerchantData.inv_data[slot]["Item"])
			valid = true
	
	# get data and create tooltip
	if valid:
		get_node("NinePatchRect/Margin/VBox/ItemName").set_text(tr(GameData.item_data[item_id]["Name"]))
		var item_stat = 1
		for i in range(GameData.item_stats.size()):
			var stat_name = GameData.item_stats[i]
			var stat_label = GameData.item_stat_labels[i]
			if GameData.item_data[item_id][stat_name] != null:
				var stat_value = GameData.item_data[item_id][stat_name]
				if stat_name != "Worth":
					get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Stat").set_text(tr(stat_label) + ": " + str(stat_value))
				else:
					get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Stat").set_text(tr(stat_label) + ": " + str(stat_value) + " Gold")
				
				if GameData.item_data[item_id]["EquipmentSlot"] != null and (origin == "Inventory" or origin == "TradeInventory") and stat_name in GameData.compare_stats:
					var stat_difference = CompareItems(item_id, stat_name, stat_value)
					if stat_difference > 0:
						get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Difference").set_text("+" + str(stat_difference))
						get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Difference").set("custom_colors/font_color", Color("3eff00"))
					elif stat_difference < 0:
						get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Difference").set_text(str(stat_difference))
						get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Difference").set("custom_colors/font_color", Color("ff0000"))
					else:
						get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Difference").set_text(str(stat_difference))
					get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Difference").show()
				
				item_stat += 1

func CompareItems(item_id, stat_name, stat_value):
	var stat_difference
	var equipment_slot = GameData.item_data[item_id]["EquipmentSlot"]
	if PlayerData.inv_data[equipment_slot]["Item"] != null:
		var item_id_current = PlayerData.inv_data[equipment_slot]["Item"]
		var stat_value_current = GameData.item_data[str(item_id_current)][stat_name]
		stat_difference = stat_value - stat_value_current
	else:
		stat_difference = stat_value
	return stat_difference
