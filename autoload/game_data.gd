extends Node

var item_data = {}
var item_stats = ["Attack", "Defense", "Block", "PotionHealth", "PotionMana", "FoodSatiation"]
var item_stat_labels = ["Attack", "Defense", "Block", "Health", "Mana", "Satiation"]

# Load the item data
func _ready():
	var item_data_file = File.new()
	item_data_file.open(Constants.ITEM_DATA_PATH, File.READ)
	var item_data_json = JSON.parse(item_data_file.get_as_text())
	item_data_file.close()
	item_data = item_data_json.result
