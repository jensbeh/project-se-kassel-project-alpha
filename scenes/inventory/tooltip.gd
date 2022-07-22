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
		get_node("NinePatchRect/Margin/VBox/ItemName").set_text(GameData.item_data[item_id]["Name"])##TODO translate
		var item_stat = 1
		for i in range(GameData.item_stats.size()):
			var stat_name = GameData.item_stats[i]
			var stat_label = GameData.item_stat_labels[i]
			if GameData.item_data[item_id][stat_name] != null:
				var stat_value = GameData.item_data[item_id][stat_name]
				get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Stat").set_text(tr(stat_label) + ": " + str(stat_value))
				
				item_stat += 1