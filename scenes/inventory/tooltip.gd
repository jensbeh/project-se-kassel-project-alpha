extends Popup

var origin = ""
var slot = ""
var valid = false

func _ready():
	var item_id
	if origin == "Inventory":
		if PlayerData.inv_data[slot]["Item"] != null:
			item_id = str(PlayerData.inv_data[slot]["Item"])
			valid = true
	else:# add later characterSheeet yet merchant
		if MerchantData.inv_data[slot]["Item"] != null:
			item_id = str(MerchantData.inv_data[slot]["Item"])
			valid = true
	
	if valid:
		get_node("NinePatchRect/Margin/VBox/ItemName").set_text(GameData.item_data[item_id]["Name"])
		var item_stat = 1
		for i in range(GameData.item_stats.size()):
			var stat_name = GameData.item_stats[i]
			var stat_label = GameData.item_stat_labels[i]
			if GameData.item_data[item_id][stat_name] != null:
				var stat_value = GameData.item_data[item_id][stat_name]
				get_node("NinePatchRect/Margin/VBox/Stats" + str(item_stat) + "/Stat").set_text(stat_label + ": " + str(stat_value))
				
				item_stat += 1
