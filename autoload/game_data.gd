extends Node

var item_data = {}

func _ready():
	var item_data_file = File.new()
	item_data_file.open("res://assets/data/ItemData.json", File.READ)
	var item_data_json = JSON.parse(item_data_file.get_as_text())
	item_data_file.close()
	item_data = item_data_json.result
