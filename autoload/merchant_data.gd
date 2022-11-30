extends Node

var inv_data = {}
var path = Constants.MERCHANTS_PATH


# Method to set the new path to the merchant
func set_path(new_path):
	path = Constants.SAVE_CHARACTER_PATH + Utils.get_current_player().data.id + "/merchants/" + new_path + "_inv_data.json"


# Method to load the merchant data to variable
func load_merchant_data():
	inv_data = FileManager.load_inventory_data(path)


# Method to save the merchant data
func save_merchant_inventory():
	FileManager.save_inventory_data(path, inv_data)
