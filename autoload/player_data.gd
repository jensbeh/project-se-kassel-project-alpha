extends Node

var inv_data = {}

# load the inventar items form the player
func _ready():
	var item_data_file = File.new()
	item_data_file.open("res://assets/data/inv_data_file.json", File.READ)
	var item_data_json = JSON.parse(item_data_file.get_as_text())
	item_data_file.close()
	inv_data = item_data_json.result
