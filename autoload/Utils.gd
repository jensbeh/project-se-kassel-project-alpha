extends Node

# Variables
var current_player : KinematicBody2D = null # Must be used in game scenes
var language = ""
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

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


func generate_mob_spawn_area_from_polygon(area_world_position, polygon) -> Dictionary:
	var triangle_points = Geometry.triangulate_polygon(polygon)
	var triangles_count = triangle_points.size() / 3
	
	var triangles = {} # 0 : complete_polygon_area; i >= 1 : [A, B, C, area, probability]
	var complete_polygon_area = 0.0
	
	# Create triangle vectors, areas
	for i in range(triangles_count):
		# Get triangle corners from triangle_points with position in world
		var A : Vector2 = area_world_position + polygon[triangle_points[3 * i + 0]]
		var B : Vector2 = area_world_position + polygon[triangle_points[3 * i + 1]]
		var C : Vector2 = area_world_position + polygon[triangle_points[3 * i + 2]]
		var area = calculate_triangle_area(A, B, C)
		complete_polygon_area += area
		triangles[i + 1] = [A, B, C, area]
	
	# Calculate the area probability for each triangle
	for triangle in triangles.values():
		triangle.append(triangle[3] / complete_polygon_area)
		
	triangles[0] = complete_polygon_area
	return triangles
	
# Method to calculate the area of a triangle with vectors
func calculate_triangle_area(A, B, C) -> float:
	var AB : Vector2 = B - A
	var AC : Vector2 = C - A
	var AxB : float = AC.x * AB.y - AB.x * AC.y
	return 0.5 * abs(AxB)
	

func generate_position_in_mob_area(area_info, navigation_tile_map : TileMap, collision_radius) -> Vector2:
	# Get weighted random triangle
	var complete_polygon_area = area_info[0] # complete_polygon_area
	var remaining_distance = randf() * complete_polygon_area
	var selected_triangle = null
	for i in range(1, area_info.size()): # without complete_polygon_area
		remaining_distance -= area_info[i][3]
		if remaining_distance < 0:
			selected_triangle = i
			break
	
	# Get random position in triangle
	var A = area_info[selected_triangle][0]
	var B = area_info[selected_triangle][1]
	var C = area_info[selected_triangle][2]
	var r1 = randf()
	var r2 = randf()
	var randX = (1 - sqrt(r1)) * A.x + (sqrt(r1) * (1 - r2)) * B.x + (sqrt(r1) * r2) * C.x
	var randY = (1 - sqrt(r1)) * A.y + (sqrt(r1) * (1 - r2)) * B.y + (sqrt(r1) * r2) * C.y
	
	var position = Vector2(randX, randY)
	
	# Check if position is valid
	var cell = navigation_tile_map.get_cell(int(floor(randX / 16)), int(floor(randY / 16)))
	var cellBottom = navigation_tile_map.get_cell(int(floor(randX / 16)), int(floor((randY + collision_radius) / 16)))
	var cellBottomRight = navigation_tile_map.get_cell(int(floor((randX + collision_radius) / 16)), int(floor((randY + collision_radius) / 16)))
	var cellRight = navigation_tile_map.get_cell(int(floor((randX + collision_radius) / 16)), int(floor(randY / 16)))
	var cellTopRight = navigation_tile_map.get_cell(int(floor((randX + collision_radius) / 16)), int(floor((randY - collision_radius) / 16)))
	var cellTop = navigation_tile_map.get_cell(int(floor(randX / 16)), int(floor((randY - collision_radius) / 16)))
	var cellTopLeft = navigation_tile_map.get_cell(int(floor((randX - collision_radius) / 16)), int(floor((randY - collision_radius) / 16)))
	var cellLeft = navigation_tile_map.get_cell(int(floor((randX - collision_radius) / 16)), int(floor(randY / 16)))
	var cellBottomLeft = navigation_tile_map.get_cell(int(floor((randX - collision_radius) / 16)), int(floor((randY + collision_radius) / 16)))
	if cell != -1 and cellBottom != -1 and cellBottomRight != -1 and cellRight != -1 and cellTopRight != -1 and cellTop != -1 and cellTopLeft != -1 and cellLeft != -1 and cellBottomLeft != -1:
		# Position is perfect
		return position
	else:
		# Position is blocked by collision, ... - get new one
		return generate_position_in_mob_area(area_info, navigation_tile_map, collision_radius)


func n_random_numbers_with_max_sum(n, sum) -> Array:
	var result : Array = []
	var part = sum / n
	for _i in range(n):
		rng.randomize()
		var num = rng.randi_range(part / 1.5, part)
		result.append(num)
	return result
