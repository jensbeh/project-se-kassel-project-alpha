extends Node

# Variables
var current_language
var finished_loading = false


# Method is called on game start -> at starting of preloading!
func on_game_start():
	# Firstly create all folder
	create_folder()
	
	# Compare game version
	check_version()
	
	# Load settings
	load_settings()
	# Load window settings
	load_window_settings()
	# Load language and music
	load_language_and_music()
	
	finished_loading = true


# Method to return if FileManager finished loading
func is_finished_loading() -> bool:
	return finished_loading


# Method to check the current game version with saved version
func check_version():
	var create_new_version = false
	
	var dir_appdata = Directory.new()
	# Check if existing
	if dir_appdata.dir_exists(Constants.APP_DATA_FOLDER_PATH):
		var dir_game = Directory.new()
		if dir_game.dir_exists(Constants.SAVE_GAME_PATH):
			
			var version_file = File.new()
			# Version file existing
			if version_file.file_exists(Constants.VERSION_PATH):
				# Load version file
				version_file.open(Constants.VERSION_PATH, File.READ)
				var build_nr = version_file.get_var(true)
				version_file.close()
				
				# Compare versions
				# Not equal -> update/delete
				if build_nr != Constants.GAME_BUILD_NR:
					printerr("FILE_MANAGER: Version not equal (old: " + str(build_nr) + ", new: " + str(Constants.GAME_BUILD_NR) + ") -> Update game")
					
					# Udpate game
					update_game(build_nr)
					
					# Need new version nr
					create_new_version = true
				
				# Equal
				else:
					print("FILE_MANAGER: Version is equal (version: " + str(Constants.GAME_BUILD_NR) + ")")
			
			# Version file NOT existing - Very old version
			else:
				printerr("FILE_MANAGER: Version file NOT existing (new: " + str(Constants.GAME_BUILD_NR) + ") -> Delete all")
				
				# Delete all
				delete_directory(Constants.APP_DATA_FOLDER_PATH)
				
				# Create folder again
				create_folder()
				
				# Need new version nr
				create_new_version = true
	
	
	# Create new version file
	if create_new_version:
		# Save version file
		var version_save_file = File.new()
		version_save_file.open(Constants.VERSION_PATH, File.WRITE)
		version_save_file.store_var(Constants.GAME_BUILD_NR)
		version_save_file.close()


# Method to update game
# Example: Build-Nr.: 1, 2, 3, 4
# 	# 1 -> 2
#	if build_nr < 2:
#		pass
#	# 2 -> 3
#	if build_nr < 3:
#		pass
#	# 3 -> 4
#	if build_nr < 4:
#		pass
func update_game(build_nr):
	print("FILE_MANAGER: Updating game...")
	# Firstly check if version file is corrupted
	if build_nr == null:
		print("FILE_MANAGER: Version file is corrupted")
		# Delete all
		delete_directory(Constants.APP_DATA_FOLDER_PATH)
		# Create folder again
		create_folder()
		return
	
	
	# Add here update cases
	
	
	
	print("FILE_MANAGER: Update finished!")


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
		Constants.GAME_SETTINGS = parse_json(save_settings.get_as_text())
		save_settings.close()
		# Set value
		current_language = Constants.GAME_SETTINGS.language
	
	# Create settings
	else:
		# Create file
		save_settings.open(Constants.SAVE_SETTINGS_PATH, File.WRITE)
		save_settings.store_line(to_json(Constants.GAME_SETTINGS))
		save_settings.close()
		# Set value
		current_language = Constants.GAME_SETTINGS.language


# Method to save settings
func save_settings():
	var save_game = File.new()
	save_game.open(Constants.SAVE_SETTINGS_PATH, File.WRITE)
	save_game.store_line(to_json(Constants.GAME_SETTINGS))
	save_game.close()


# Method to load language and music
func load_language_and_music():
	# Sets the Langauge and the sound/music volume
	Utils.set_language(current_language)
	Utils.set_music_volume(Constants.GAME_SETTINGS.music)
	AudioServer.set_bus_volume_db(1, Constants.GAME_SETTINGS.music)
	if float(Constants.GAME_SETTINGS.music) == -40:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
	Utils.set_sound_volume(Constants.GAME_SETTINGS.sound)
	AudioServer.set_bus_volume_db(2, Constants.GAME_SETTINGS.sound)
	if float(Constants.GAME_SETTINGS.sound) == -40:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
	TranslationServer.set_locale(current_language)
	Utils.set_and_play_music(Constants.PreloadedMusic.Menu_Music)


# Method to load the window settings
func load_window_settings():
	# Load valid window sizes depending on current screen size
	Constants.load_valid_window_sizes()
	
	# Set window fullscreen
	Utils.set_window_fullscreen(Constants.GAME_SETTINGS.window_fullscreen, true)
	# Set window maximized and size
	if Constants.GAME_SETTINGS.window_maximized:
		# Set window maximized
		Utils.set_window_size(str2var(Constants.GAME_SETTINGS.window_size), false)
		Utils.set_window_maximized(Constants.GAME_SETTINGS.window_maximized, true)
	else:
		# Set window size
		Utils.set_window_size(str2var(Constants.GAME_SETTINGS.window_size), true)
		Utils.set_window_maximized(Constants.GAME_SETTINGS.window_maximized, false)
	
	# Set minimum size to window
	OS.set_min_window_size(Constants.WINDOW_SIZES.values()[0].value)


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
func delete_character(character_id: String):
	delete_directory(Constants.SAVE_CHARACTER_PATH + character_id + "/")


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


# Method to delete recursive the given directory
# Sample path -> "user://character/test/"
func delete_directory(dir_path : String):
	var dir = Directory.new()
	# Open stream/dir
	dir.open(dir_path)
	dir.list_dir_begin()
	
	while true:
		var file_or_dir = dir.get_next()
		if file_or_dir == "":
			break
		
		elif !file_or_dir.begins_with("."):
			# Case: Directory
			if dir.current_is_dir():
				delete_directory(dir_path + file_or_dir + "/")
			# Case: File
			else:
				dir.remove(dir_path + file_or_dir)
	
	# End stream
	dir.list_dir_end()
	
	# Remove this dir
	dir.remove(dir_path)
