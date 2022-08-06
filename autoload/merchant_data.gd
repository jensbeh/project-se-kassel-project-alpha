extends Node

var inv_data = {}
var path = Constants.MERCHANT

# Load the inventory items form the merchant
func _ready():
	var item_data_file = File.new()
	# Data file changes for diffrent merchants
	item_data_file.open(path, File.READ)
	var item_data_json = JSON.parse(item_data_file.get_as_text())
	item_data_file.close()
	inv_data = item_data_json.result
	

func set_path(new_path):
	path = "res://assets/data/" + new_path + "_inv_data.json"

func save_merchant_inventory():
	var item_data_file = File.new()
	item_data_file.open(path, File.WRITE)
	item_data_file.store_line(to_json(inv_data))
	item_data_file.close()
