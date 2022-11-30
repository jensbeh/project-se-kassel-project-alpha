extends Node

# Variables
var current_language
var settings_dic = {
		"language": "en",
		"sound": Constants.DEFAULT_SOUND_VOLUME,
		"music": Constants.DEFAULT_MUSIC_VOLUME
	}


# Method is called on game start -> at starting of preloading!
func on_game_start():
	# Firstly create all folder
	create_folder()
	
	# Load settings
	load_settings()
	# Load language and music
	load_language_and_music()


# Method to create all folder
func create_folder():
	# Create game folder
	var dir_game = Directory.new()
	if !dir_game.dir_exists(Constants.SAVE_GAME_PATH):
		dir_game.make_dir(Constants.SAVE_GAME_PATH)
	# Create character folder
	var dir_character = Directory.new()
	if !dir_character.dir_exists(Constants.SAVE_CHARACTER_PATH):
		dir_character.make_dir(Constants.SAVE_CHARACTER_PATH)


# Method to load settings
func load_settings():
	var save_settings = File.new()
	# Load settings
	if save_settings.file_exists(Constants.SAVE_SETTINGS_PATH):
		save_settings.open(Constants.SAVE_SETTINGS_PATH, File.READ)
		settings_dic = parse_json(save_settings.get_as_text())
		save_settings.close()
		current_language = settings_dic.language
	
	# Create settings
	else:
		# Create file
		save_settings.open(Constants.SAVE_SETTINGS_PATH, File.WRITE)
		save_settings.store_line(to_json(settings_dic))
		save_settings.close()
		# Set values
		current_language = "en"
		settings_dic.sound = Constants.DEFAULT_SOUND_VOLUME # Sets to half
		settings_dic.music = Constants.DEFAULT_MUSIC_VOLUME # Sets to half


# Method to save settings
func save_settings(setting_data):
	var save_game = File.new()
	save_game.open(Constants.SAVE_SETTINGS_PATH, File.WRITE)
	save_game.store_line(to_json(setting_data))
	save_game.close()


# Method to load language and music
func load_language_and_music():
	# Sets the Langauge and the sound/music volume
	Utils.set_language(current_language)
	Utils.set_music_volume(settings_dic.music)
	AudioServer.set_bus_volume_db(1, settings_dic.music)
	if float(settings_dic.music) == -40:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
	Utils.set_sound_volume(settings_dic.sound)
	AudioServer.set_bus_volume_db(2, settings_dic.sound)
	if float(settings_dic.sound) == -40:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
	TranslationServer.set_locale(current_language)
	Utils.set_and_play_music(Constants.PreloadedMusic.Menu_Music)


# Method to load the astar points and connections from file -> file generated through reimport
func load_astar_files():
	var astar_files_dic = {}
	# Check if directory is existing
	var dir_game_pathfinding = Directory.new()
	if dir_game_pathfinding.open(Constants.SAVE_GAME_PATHFINDING_PATH) == OK:
		dir_game_pathfinding.list_dir_begin()
		var file_name = dir_game_pathfinding.get_next()
		while file_name != "":
			# Check for file extensions
			if (file_name.get_extension() == "sav"):
				var file_name_without_suffix = file_name.substr(0, file_name.find_last(".sav"))
				
				var astar_load = File.new()
				astar_load.open(Constants.SAVE_GAME_PATHFINDING_PATH + file_name, File.READ)
				var dic = astar_load.get_var(true)
				astar_load.close()
				
				astar_files_dic[file_name_without_suffix] = dic
			
			file_name = dir_game_pathfinding.get_next()
		
		return astar_files_dic
	
	else:
		printerr("ERROR: An error occurred when trying to access the PATHFINDING PATH.")


# Method to create the character data
func create_character(save_game_data: Dictionary):
	# Create character folder
	var dir_character = Directory.new()
	if !dir_character.dir_exists(Constants.SAVE_CHARACTER_PATH + save_game_data.id + "/"):
		dir_character.make_dir(Constants.SAVE_CHARACTER_PATH + save_game_data.id + "/")
	# Create character file
	var save_game = File.new()
	save_game.open(Constants.SAVE_CHARACTER_PATH + save_game_data.id + "/" + save_game_data.name + ".json", File.WRITE)
	save_game.store_line(to_json(save_game_data))
	save_game.close()
	print("FILE_MANAGER: Player data saved")
	
	# Load template character data
	var default_player_inv_file = File.new()
	default_player_inv_file.open(Constants.DEFAULT_PLAYER_INV_PATH, File.READ)
	var default_player_inv = JSON.parse(default_player_inv_file.get_as_text())
	default_player_inv_file.close()
	# Save template character data to new character
	var save_character = File.new()
	save_character.open(Constants.SAVE_CHARACTER_PATH + save_game_data.id + "/" + save_game_data.name + "_inv_data.json", File.WRITE)
	save_character.store_line(to_json(default_player_inv.result))
	save_character.close()
	
	# Create merchants data files for this character
	var dir_merchants = Directory.new()
	dir_merchants.make_dir(Constants.SAVE_CHARACTER_PATH + save_game_data.id + "/merchants/")
	var merchants_data = File.new()
	for i in ["bella", "heinz", "lea", "sam", "haley"]:
		# Get template merchant data and save to new character
		var item_data_file = File.new()
		item_data_file.open("res://assets/data/" + i + "_inv_data.json", File.READ)
		var item_data_json = JSON.parse(item_data_file.get_as_text())
		item_data_file.close()
		merchants_data.open(Constants.SAVE_CHARACTER_PATH + save_game_data.id + "/merchants/" + i + "_inv_data.json", File.WRITE)
		merchants_data.store_line(to_json(item_data_json.result))
		merchants_data.close()


# Method to load all character with data
func load_all_character_with_data() -> Array:
	var players_list : Array = []
	
	var dir = Directory.new()
	dir.open(Constants.SAVE_CHARACTER_PATH)
	dir.list_dir_begin()
	while true:
		# List all character folder
		var file = dir.get_next()
		if file == "":
			break
		elif !file.begins_with("."):
			var save_path = Directory.new()
			save_path.open(Constants.SAVE_CHARACTER_PATH + file)
			save_path.list_dir_begin()
			while true:
				# Get files inside character folder
				var data_file = save_path.get_next()
				if data_file == "":
					break
				elif data_file.ends_with(".json") and !"inv_data" in data_file.get_basename() and !file.begins_with("."):
					data_file.get_file()
					var save_game = File.new()
					save_game.open(Constants.SAVE_CHARACTER_PATH + file + "/" + data_file, File.READ)
					var save_game_data = {}
					save_game_data = parse_json(save_game.get_line())
					save_game.close()
					players_list.append(save_game_data)
			
			save_path.list_dir_end()
	dir.list_dir_end()
	
	return players_list


# Method to delete the character depending on id and name
func delete_character(character_id: String, character_name: String):
	var dir = Directory.new()
	if dir.file_exists(Constants.SAVE_CHARACTER_PATH + character_id + "/" + character_name + ".json"):
		dir.remove(Constants.SAVE_CHARACTER_PATH + character_id + "/" + character_name + ".json")
	# remove inventory data
	if dir.dir_exists(Constants.SAVE_CHARACTER_PATH + character_id + "/"):
		for i in ["bella", "heinz", "lea", "sam", "haley", character_id]:
			dir.remove(Constants.SAVE_CHARACTER_PATH + character_id + "/merchants/" + i + "_inv_data.json")
		dir.remove(Constants.SAVE_CHARACTER_PATH + character_id + "/merchants/")
		dir.remove(Constants.SAVE_CHARACTER_PATH + character_id + "/" + character_name + "_inv_data.json")
		dir.remove(Constants.SAVE_CHARACTER_PATH + character_id + "/")


# Method to save the player data
func save_player_data(player_data):
	var save_game = File.new()
	save_game.open(Constants.SAVE_CHARACTER_PATH + player_data.id + "/" + player_data.name + ".json", File.WRITE)
	save_game.store_line(to_json(player_data))
	save_game.close()


# Method to load the inventory items of the character/merchants
func load_inventory_data(path) -> Dictionary:
	var item_data_file = File.new()
	# Data file change for diffrent characters
	item_data_file.open(path, File.READ)
	var item_data_json = JSON.parse(item_data_file.get_as_text())
	item_data_file.close()
	var inv_data = item_data_json.result
	return inv_data


# Method to save the inventory data
func save_inventory_data(path, inv_data):
	var item_data_file = File.new()
	item_data_file.open(path, File.WRITE)
	item_data_file.store_line(to_json(inv_data))
	item_data_file.close()


# Method to load the biome data depending on biome_name
func load_biome_data(biome_name):
	var file = File.new()
	file.open("res://assets/biomes/"+ biome_name + ".json", File.READ)
	var biome_json = parse_json(file.get_as_text())
	return biome_json


# Method to load the dialog text from path
func load_dialog_data(dialog_path) -> Array:
	var dialog_file = File.new()
	if dialog_file.file_exists(dialog_path):
		dialog_file.open(dialog_path, File.READ)
		var json = dialog_file.get_as_text()
		var output = parse_json(json)
		if typeof(output) == TYPE_ARRAY:
			return output
	return []
