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


# Method to disable gui in viewport
func disable_game_gui(disable_gui):
	game_viewport.gui_disable_input = disable_gui


# Method to start skip time animation
func start_skip_time_transition():
	Utils.get_current_player().pause_player(true)
	loading_screen_animation_player.play("SkipTimeFadeToBlack")


# Method to skip time - called from animtaion "SkipTimeFadeToBlack" when it ends
func on_skip_time_start():
	DayNightCycle.skip_time(8,true)
	
	# Reset player stats
	Utils.get_current_player().set_current_health(Utils.get_current_player().get_max_health())
	Utils.get_current_player().set_current_stamina(Utils.get_current_player().get_max_stamina())
	
	# Wait till time changed
	yield(DayNightCycle, "on_skip_time_updated")
	
	# Save game
	Utils.save_game(true)
	
	# Fade back to normal
	loading_screen_animation_player.play("SkipTimeFadeToNormal")


# Method is called from animtaion "SkipTimeFadeToNormal" when it ends
func on_skip_time_end():
	Utils.get_current_player().pause_player(false)


# Method to start close game animation - calls ONLY from UTILS
func start_close_game_transition():
	loading_screen_animation_player.play("CloseGameFadeToBlack")


# Method to stop the game after animation "CloseGameFadeToBlack" is done - called from animation "CloseGameFadeToBlack"
func stop_game():
	# Pause game
	Utils.pause_game(true)
	
	# Cleanup previous scene
	if Utils.get_scene_manager().get_current_scene().has_method("destroy_scene"):
		Utils.get_scene_manager().get_current_scene().destroy_scene()
		print("MAIN: Destroyed scene: \"" + str(Utils.get_scene_manager().get_current_scene().name) + "\"")
	else:
		printerr("MAIN: NOT destroyed scene: \"" + str(Utils.get_scene_manager().get_current_scene().name) + "\"")
	
	# Stop threads -> autoloads
	# Stop Chunkloader
	ChunkLoaderService.stop()
	# Stop Pathfinder
	PathfindingService.stop()
	# Stop Mobspawner
	MobSpawnerService.stop()
	
	# Quit and close game
	get_tree().quit()
	
	print("GAME: Stopped!")


# Handle notifications
func _notification(notification):
	# If game is closed
	if notification == NOTIFICATION_WM_QUIT_REQUEST:
		print("GAME: Game closed signal received")
		stop_game()
	# Window size, ... changed
	elif notification == 30:
		print("GAME: Window resized signal received")
		if FileManager.is_finished_loading():
			# Check if window maximize changed
			var window_maximize_changed = false
			if Utils.get_window_maximized() != OS.is_window_maximized():
				# Window maximize changed without changing settings in settings screen
				# Save new window maximize
				Utils.set_window_maximized(OS.is_window_maximized(), false)
				Constants.GAME_SETTINGS.window_maximized = OS.is_window_maximized()
				window_maximize_changed = true
			
			# Check if window size changed
			var window_size_changed = false
			if Utils.get_window_size() != OS.get_window_size():
				Constants.GAME_SETTINGS.window_size = var2str(OS.get_window_size())
				# Save new window size
				Utils.set_window_size(OS.get_window_size(), false)
				window_maximize_changed = true
			
			# Update ui and save settings if something changed
			if window_maximize_changed or window_size_changed:
				# Update ui if in settings screen
				if Utils.get_settings_screen() != null:
					Utils.get_settings_screen().update_ui()
				
				# Save settings
				FileManager.save_settings()


func play_save_notification():
	get_node("LoadingScreen/SaveScreen").play("Saved")
