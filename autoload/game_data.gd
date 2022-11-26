extends Node

var loot_data = {}
var item_data = {}
var item_stats = ["Attack", "Health", "Attack-Speed", "Knockback", "Radius", "Stamina", "Worth"]
var item_stat_labels = ["Attack", "Health", "Speed", "Knockback", "Radius", "Stamina", "Worth"]
var compare_stats = ["Attack", "Attack-Speed", "Knockback", "Radius"]

# dropable item IDs
# CHANGE!!
var jewel_IDs = [10046, 10047, 10048, 10049] # With tag "Jewel" - 10046: Diamond, 10047: Rubin, 10048: Smaragd, 10049: Saphir
var weapon_IDs = [10001, 10002, 10003, 10008] # With tag "Weapon" - 10001: wooden sword, 10002: iron sword, 10003: balanced sword, 10008: normal axt
var food_IDs = [10026, 10027, 10029, 10030] # With tag "Potion" - 10026: apple, 10027: carrot, 10029: meat, 10030: fish
var treasure_potion_IDs = [10011, 10012, 10013, 10014] # With tags "Potion" & "Treasure" - 10011: health potion, 10012: stamina potion, 10013: good health potion, 10014: good stamina potion


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
