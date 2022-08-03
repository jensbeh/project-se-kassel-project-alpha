extends Node

var inv_data = {}
var equipment_data = {
	"Weapon": {
		"Item": null,
		"Stack": null,
	},
}
var path = "res://assets/data/inv_data_file.json"

# Load the inventar items form the player
func _ready():
	var item_data_file = File.new()
	# Data file change for diffrent characters
	item_data_file.open(path, File.READ)
	var item_data_json = JSON.parse(item_data_file.get_as_text())
	item_data_file.close()
	inv_data = item_data_json.result
	equipment_data = item_data_json.result["Weapon"]


func set_path(new_path):
	path = "user://data/" + new_path + "_inv_data.json"
	
func save_inventory():
	var item_data_file = File.new()
	item_data_file.open(path, File.WRITE)
	item_data_file.store_line(to_json(inv_data))
	item_data_file.close()
