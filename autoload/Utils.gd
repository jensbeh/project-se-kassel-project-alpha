extends Node

# Variables
var current_player : KinematicBody2D = null # Must be used in game scenes
var language = ""
var prev_scene

func _ready():
	pass

# Returns the player in the loaded current_scene
func get_player():
	return get_node("/root/SceneManager/CurrentScene").get_children().back().find_node("Player")

# Sets a new current_player instance (firstly done when enter the game - not available in the menu)
func set_current_player(new_current_player: KinematicBody2D):
	current_player = new_current_player
	
# Returns the current_player instance
func get_current_player():
	return current_player

# Returns the scene_manager instance
func get_scene_manager():
	return get_node("/root/SceneManager")

func set_language(lang):
	language = lang
	
func get_language():
	return language

func set_prev_scene(scene):
	prev_scene = scene

func get_prev_scene():
	return prev_scene

# Method to calculate the new player_position and view_direction with the transition_data and sets the spawn of the current player
func calculate_and_set_player_spawn(scene: Node, init_transition_data):
	var player_position = Vector2(0,0)
	var view_direction = Vector2(0,0)
	
	# When transition is with custom position
	if init_transition_data.is_type(TransitionData.GamePosition):
		player_position = init_transition_data.get_player_position()
		view_direction = init_transition_data.get_view_direction()
	
	# When transition is with area to spawn on
	elif init_transition_data.is_type(TransitionData.GameArea):
		var player_spawn_area = null
		for child in scene.find_node("playerSpawns").get_children():
			if "player_spawn" in child.name:
				if child.has_meta("spawn_area_id"):
					if child.get_meta("spawn_area_id") == init_transition_data.get_spawn_area_id():
						player_spawn_area = child
						break

		player_position = Vector2(player_spawn_area.position.x + 5, player_spawn_area.position.y)
		view_direction = init_transition_data.get_view_direction()
		
	# Set the player_position and the view_direction to the current_player
	current_player.set_spawn(player_position, view_direction)
	
	
func update_current_scene_type(transition_data):
	# Menu
	if Constants.MENU_FOLDER in transition_data.get_scene_path():
		print("Menu state")
		return Constants.SceneType.MENU
	
	# Camp
	if Constants.CAMP_FOLDER in transition_data.get_scene_path():
		print("Camp state")
		return Constants.SceneType.CAMP
	
	# Grassland
	elif Constants.GRASSLAND_FOLDER in transition_data.get_scene_path():
		print("Grassland state")
		return Constants.SceneType.GRASSLAND
	
	# Dungeons
	elif Constants.DUNGEONS_FOLDER in transition_data.get_scene_path():
		print("Dungeons state")
		return Constants.SceneType.DUNGEON
