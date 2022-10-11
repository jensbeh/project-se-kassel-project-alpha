extends Node2D


# Nodes
onready var game_viewport_container = $Game
onready var game_viewport = $Game/Viewport
onready var minimap = $UI/Minimap
onready var ui = $UI

# Node DayNight Cycle
onready var darkness_lights_screen = $DarknessLightsCanvasLayer/DarknessLightsScreen

# Nodes LoadingScreen
onready var black_screen = $LoadingScreen/BlackScreen
onready var loading_screen_animation_player = $LoadingScreen/AnimationPlayerBlackScreen


func _ready():
	# Set world / what game_viewport sees to minimap_viewport
	minimap.setup_viewport(game_viewport)
	
	# Set size of fade screen
	black_screen.rect_size = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))


# Method to set mouse filter on black screen -> called from scene manager
func set_black_screen_mouse_filter(mouse_filter):
	black_screen.mouse_filter = mouse_filter


# Method to play a loading screen animation -> called from scene manager
func play_loading_screen_animation(animaiton_name):
	loading_screen_animation_player.play(animaiton_name)


# Method returns true if day night cycle is enabled otherwise false FROM light_manager
func is_day_night_cycle():
	return darkness_lights_screen.get_is_day_night_cycle()


# Method to show death screen
func show_death_screen():
	# Load death screen to ui
	if Utils.get_ui() != null:
		ui.add_child(load(Constants.DEATH_SCREEN_PATH).instance())


# Method to add settings screen to view
func add_settings():
	if (Utils.get_scene_manager().get_child(0).get_node_or_null("MainMenuScreen")) != null:
		# Called Settings from MainMenuScreen
		# Need to disable to gui in viewport of game
		disable_game_gui(true)
		
	# Add settings screen
	add_child(load(Constants.SETTINGS_PATH).instance())


# Method to disable gui in viewport
func disable_game_gui(disable_gui):
	game_viewport.gui_disable_input = disable_gui


# Method to start close game animation - calls ONLY from UTILS
func start_close_game_transition():
	loading_screen_animation_player.play("CloseGameFadeToBlack")


# Method to stop the game after animation "CloseGameFadeToBlack" is done - called from animation "CloseGameFadeToBlack"
func stop_game():
	# Cleanup previous scene
	if Utils.get_scene_manager().get_current_scene().has_method("destroy_scene"):
		Utils.get_scene_manager().get_current_scene().destroy_scene()
		print("----> destroyed scene: \"" + str(Utils.get_scene_manager().get_current_scene().name) + "\"")
	else:
		printerr("----> NOT destroyed scene: \"" + str(Utils.get_scene_manager().get_current_scene().name) + "\"")
	
	# Stop threads
	# Stop Chunkloader
	ChunkLoaderService.stop()
	# Stop Pathfinder
	PathfindingService.stop()
	# Stop Mobspawner
	MobSpawnerService.stop()
	
	# Quit and close game
	get_tree().quit()


# Handle notifications
func _notification(notification):
	# If game is closed
	if (notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		Utils.stop_game()
