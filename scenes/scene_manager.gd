extends Node2D

# Signals
signal scene_type_updated

# Variables
var current_scene_type = Constants.SceneType.MENU # Default on startup -> Menu
var previouse_scene_path = ""
var current_transition_data = null
var previouse_transition_data = null
var show_rescue_pay = false

# Nodes CurrentScreen
onready var current_scene = $CurrentScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Method to start transition to next scene with transition_data information
func transition_to_scene(transition_data):
	# Pause player
	if Utils.get_current_player() != null:
		Utils.get_current_player().pause_player(true)
	
	# Set new and current transition_data
	previouse_transition_data = current_transition_data
	current_transition_data = transition_data
	
	# Mouse actions will be stopped until transition is done
	Utils.get_main().set_black_screen_mouse_filter(Control.MOUSE_FILTER_STOP)
	
	# Disabel movment & interaction of player
	if Utils.get_current_player() != null:
		Utils.get_current_player().set_movement(false)
		Utils.get_current_player().set_movment_animation(false)
		Utils.get_current_player().set_player_can_interact(false)
		Utils.get_current_player().make_player_invisible(true)
	
	# Cleanup UI
	# Remove "ESC" Game Menu
	if Utils.get_game_menu() != null:
		Utils.remove_game_menu()
	# Remove "I" Inventory
	if Utils.get_character_interface() != null:
		Utils.get_character_interface().exit_scene()
	
	# Show black fade/loading screen and load new scene after fading to black
	if current_transition_data.get_transition_type() == Constants.TransitionType.GAME_SCENE:
		Utils.get_main().play_loading_screen_animation("GameFadeToBlack")
	elif current_transition_data.get_transition_type() == Constants.TransitionType.MENU_SCENE:
		Utils.get_main().play_loading_screen_animation("MenuFadeToBlack")


# Method is called from fadeToBlackAnimation after its done
func load_new_scene():
	# Pause game
	Utils.pause_game(true)
	
	var scene_path = current_transition_data.get_scene_path()
	
	var scene = Constants.PreloadedMenusAndMaps[scene_path].instance()
	print("GAME: Loaded new scene \"" + str(scene_path) + "\"")
	pass_data_to_scene(scene)
	
	# Cleanup previous scene
	if get_current_scene().has_method("destroy_scene"):
		get_current_scene().destroy_scene()
		print("SCENE_MANAGER: Destroyed scene: \"" + str(get_current_scene().name) + "\"")
	else:
		printerr("SCENE_MANAGER: NOT destroyed scene: \"" + str(get_current_scene().name) + "\"")
	
	# Cleanup UI
	# Remove death screen
	if Utils.get_death_screen() != null:
		Utils.remove_death_screen()
	
	# Save player node before deleting the scene
	if Utils.get_current_player() != null and Utils.get_current_player().get_parent() != null:
		Utils.get_current_player().get_parent().remove_child(Utils.get_current_player())
	
	# Cleanup player if coming from game_scene to menu
	if current_transition_data.get_transition_type() == Constants.TransitionType.MENU_SCENE and Utils.get_current_player() != null:
		if current_transition_data.get_scene_path() != Constants.STORY_SCENE_PATH:
			Utils.set_current_player(null)
	
	# Add scene to current_scene
	get_current_scene().queue_free()
	current_scene.call_deferred("add_child", scene)


# Method to pass the transition_data to the new scene 
func pass_data_to_scene(scene):
	if current_transition_data.get_transition_type() != Constants.TransitionType.MENU_SCENE:
		scene.set_transition_data(current_transition_data)


# Method must be called from _ready() of the new scene to say that the loading is finished and the transition can be fadeToNormal
func finish_transition():
	if Utils.get_sound_player().stream == Constants.PreloadedSounds.Steps_Stairs:
		Utils.get_sound_player().stop()
	# Update previouse scene path to return to it if necessary
	update_previouse_scene_path()
	
	if current_transition_data != null: # In menu it is null
		# Update current_scene_type from the new scene like MENU, CAMP, ...
		update_scene_type(current_transition_data)
		
		# When finished setting up new scene fade back to normal
		if current_transition_data.get_transition_type() == Constants.TransitionType.GAME_SCENE:
			
			# Set player scale/movment ability/movment animation/shadow/interaction back to normal
			if Utils.get_current_player().scale != Vector2(Constants.PLAYER_TRANSFORM_SCALE, Constants.PLAYER_TRANSFORM_SCALE):
				Utils.get_current_player().scale = Vector2(Constants.PLAYER_TRANSFORM_SCALE, Constants.PLAYER_TRANSFORM_SCALE)
			if Utils.get_current_player().get_movement() == false:
				Utils.get_current_player().set_movement(true)
			if Utils.get_current_player().get_movment_animation() == false:
				Utils.get_current_player().set_movment_animation(true)
			if Utils.get_current_player().get_visibility("Shadow") == true:
				Utils.get_current_player().set_visibility("Shadow", false)
			if Utils.get_current_player().get_player_can_interact() == false:
				Utils.get_current_player().set_player_can_interact(true)
			if Utils.get_current_player().is_player_dying() == true:
				show_rescue_pay = true
				Utils.get_current_player().reset_player_after_dying()
			if Utils.get_current_player().is_player_invisible() == true:
				Utils.get_current_player().make_player_invisible(false)
			if Utils.get_current_player().hurting:
				Utils.get_current_player().hurting = false
			if Utils.get_current_player().is_attacking:
				Utils.get_current_player().is_attacking = false
			if Utils.get_current_player().is_in_safe_area() == true:
				Utils.get_current_player().set_in_safe_area(false)
			if Utils.get_current_player().is_in_change_scene_area() == true:
				Utils.get_current_player().set_in_change_scene_area(false)
			
			# Save Player Data
			if previouse_transition_data.get_transition_type() != Constants.TransitionType.MENU_SCENE:
				Utils.save_game(true)
			
			# Resume game
			Utils.pause_game(false)
			
			# Start fade to normal to game
			Utils.get_main().play_loading_screen_animation("GameFadeToNormal")
			Utils.get_ui().in_world(true)
			
		elif current_transition_data.get_transition_type() == Constants.TransitionType.MENU_SCENE:
			# Start fade to normal to menu
			Utils.get_main().play_loading_screen_animation("MenuFadeToNormal")
			Utils.get_ui().in_world(false)
		
		# Update minimap
		Utils.get_minimap().update_minimap()
		
		# Mouse actions works now again
		Utils.get_main().set_black_screen_mouse_filter(Control.MOUSE_FILTER_IGNORE)


# Method is called when "GameFadeToNormal" animation finished and game is back to normal
func on_game_fade_to_normal_finished():
	# Resume player
	Utils.get_current_player().pause_player(false)
	
	if show_rescue_pay:
		Utils.get_current_player().rescue_pay()
		show_rescue_pay = false


# Method to update the current_scene_type and emits a signal
func update_scene_type(new_transition_data):
	current_scene_type = Utils.update_current_scene_type(new_transition_data)
	emit_signal("scene_type_updated")


# Method to return the previouse_scene_path
func get_previouse_scene_path():
	return previouse_scene_path


# Method to return the current_scene_type
func get_current_scene_type():
	return current_scene_type


# Method to update the previouse_scene_path
func update_previouse_scene_path():
	if current_transition_data != null: # In menu (after start) it is null
		previouse_scene_path = current_transition_data.get_scene_path()
	else:
		previouse_scene_path = "res://scenes/MainMenuScreen.tscn" # On start up


# Method to return the current scene
func get_current_scene():
	return current_scene.get_child(0)


# Method to set new current scene without any special calls or transition
# new_current_scene_path -> must be scene path
func without_transition_to_scene(new_current_scene_path : String):
	# Cleanup previous scene
	if get_current_scene().has_method("destroy_scene"):
		get_current_scene().destroy_scene()
		print("SCENE_MANAGER: Destroyed scene: \"" + str(get_current_scene().name) + "\"")
	else:
		printerr("SCENE_MANAGER: NOT destroyed scene: \"" + str(get_current_scene().name) + "\"")
	
	# Remove previous scene
	get_current_scene().queue_free()
	
	# Load new scene
	var scene = Constants.PreloadedMenusAndMaps[new_current_scene_path].instance()
	print("GAME: Loaded new scene \"" + str(new_current_scene_path) + "\"")
	current_scene.call_deferred("add_child",scene)
