extends Node

var inv_data = {}
var equipment_data = {
	"Weapon": {
		"Item": null,
		"Stack": null,
	},
	"Light": {
		"Item": null,
		"Stack": null,
	},
	"Hotbar": {
		"Item": null,
		"Stack": null,
	},
}
var path = Constants.DEFAULT_PLAYER_INV_PATH


# Method to set the new path to the character
func set_path(new_path):
	path = Constants.SAVE_CHARACTER_PATH + new_path + "/" + Utils.get_current_player().get_data().name + "_inv_data.json"


# Method to load the player data to variables
func load_player_data():
	inv_data = FileManager.load_inventory_data(path)
	equipment_data = {"Weapon": inv_data["Weapon"], 
					"Light": inv_data["Light"],
					"Hotbar": inv_data["Hotbar"],
					}


# Method to save the player data
func save_inventory():
	FileManager.save_inventory_data(path, inv_data)
