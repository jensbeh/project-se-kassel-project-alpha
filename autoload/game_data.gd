extends Node

var loot_data = {}
var item_data = {}
var item_stats = ["Attack", "Health", "Attack-Speed", "Knockback", "Radius", "Worth"]
var item_stat_labels = ["Attack", "Health", "Speed", "Knockback", "Radius", "Worth"]
var compare_stats = ["Attack", "Attack-Speed", "Knockback", "Radius"]
# dropable item IDs 
var jewel_IDs = [10046, 10047, 10048, 10049]
var weapon_IDs = [10001, 10002, 10004, 10008]
var potion_IDs = [10026, 10027, 10030, 10029, 10011]

# Load the item data
func _ready():
	var item_data_file = File.new()
	item_data_file.open(Constants.ITEM_DATA_PATH, File.READ)
	var item_data_json = JSON.parse(item_data_file.get_as_text())
	item_data_file.close()
	item_data = item_data_json.result
	
	# loot data
	var loot_data_file = File.new()
	loot_data_file.open(Constants.LOOT_DATA_PATH, File.READ)
	var loot_data_json = JSON.parse(loot_data_file.get_as_text())
	loot_data_file.close()
	loot_data = loot_data_json.result
