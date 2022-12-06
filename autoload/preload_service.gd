extends Node


# Signals
signal preload_first_done
signal preload_done

# Variables
var preload_thread = Thread.new()
var is_preloading = false
var preloaded_maps = []


# Called when the node enters the scene tree for the first time.
func _ready():
	print("PRELOAD_SERVICE: Start")
	# Start preload thread
	preload_thread.start(self, "preload_game")


# Method to stop the preloader
func stop():
	# Reset variables
	is_preloading = null
	
	print("PRELOAD_SERVICE: Stopped")


# Method to cleanup the preloader
func cleanup():
	# Check if thread is active wait to stop
	is_preloading = false
	if preload_thread.is_active():
		clean_thread()
	
	print("PRELOAD_SERVICE: Cleaned")


# Method to do stuff in background
func preload_game():
#	while is_preloading:
#		pass
	
	print("GAME: Preloading...")
	# Measure time
	var time_start = OS.get_system_time_msecs()
	var time_now = 0
	
	is_preloading = true
	
	# Load here everything which needs to be preloaded
	# Preload all scenes, music, ...
	
	
	
	# Preload stuff which is necessary to reach the menu
	# Create/Load game files
	FileManager.on_game_start()
	# Load variables
	Constants.preload_variables()
	emit_signal("preload_first_done")
	
	
	
	# Preload stuff which can be loaded while in menu
	# Load AStars
	var _error = PathfindingService.connect("map_loaded", self, "on_map_loaded")
	PathfindingService.preload_astars()
	
	
	
	is_preloading = false
	emit_signal("preload_done")
	
	# Calculate needed time
	time_now = OS.get_system_time_msecs()
	var time_elapsed = time_now - time_start
	
	
	print("GAME: Preload finished! (" + str(time_elapsed / 1000.0) + " sec)")
	
	clean_thread()


# Method is called when thread finished
func clean_thread():
	# Wait for thread to finish
	preload_thread.wait_to_finish()


# Method to preload game -> called ONLY! from StartScreen
# When adding here some preloads need to stop in following method in case game is closing while loading


# Method to stop preloading -> is called if game is closed while loading/StartScreen
func stop_preload_game():
	if is_preloading:
		Constants.stop_preloading()
		PathfindingService.stop_preloading()


func is_game_preloading():
	return is_preloading


func on_map_loaded(map_name):
	print("AAAAAAA: " + str(map_name))
	preloaded_maps.append(map_name)

func is_map_loaded(scene_path):
	# Check if map is map with astar else return
	if Constants.ASTAR_MAP_NAMES_PATHES.values().find(scene_path) == -1:
		return true
	
	# Check if map is loaded
	for preloaded_map in preloaded_maps:
		if Constants.ASTAR_MAP_NAMES_PATHES[preloaded_map] == scene_path:
			# Map loaded
			return true
	
	# Map not loaded
	return false
