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
		var player_spawn_area : Area2D = null
		for child in scene.find_node("playerSpawns").get_children():
			if "player_spawn" in child.name:
				if child.has_meta("spawn_area_id"):
					if child.get_meta("spawn_area_id") == init_transition_data.get_spawn_area_id():
						player_spawn_area = child
						break
		var shape : RectangleShape2D = player_spawn_area.get_child(0).shape
		var top_left = player_spawn_area.position
		var half_width = int((shape.extents.x * 2) / 2)
		var half_heigth = int((shape.extents.y * 2) / 2)
		player_position = Vector2(top_left.x + half_width, top_left.y + half_heigth)
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
	

func generate_position_in_mob_area(area_info, navigation_tile_map : TileMap, collision_radius, is_first_spawning) -> Vector2:
	var position = generate_position_in_polygon(area_info, is_first_spawning)
	var tile_set : TileSet = navigation_tile_map.tile_set
	
	# Check if position is valid
	var cell = navigation_tile_map.get_cell(int(floor(position.x / 16)), int(floor(position.y / 16)))
	var cellBottom = navigation_tile_map.get_cell(int(floor(position.x / 16)), int(floor((position.y + collision_radius) / 16)))
	var cellBottomRight = navigation_tile_map.get_cell(int(floor((position.x + collision_radius) / 16)), int(floor((position.y + collision_radius) / 16)))
	var cellRight = navigation_tile_map.get_cell(int(floor((position.x + collision_radius) / 16)), int(floor(position.y / 16)))
	var cellTopRight = navigation_tile_map.get_cell(int(floor((position.x + collision_radius) / 16)), int(floor((position.y - collision_radius) / 16)))
	var cellTop = navigation_tile_map.get_cell(int(floor(position.x / 16)), int(floor((position.y - collision_radius) / 16)))
	var cellTopLeft = navigation_tile_map.get_cell(int(floor((position.x - collision_radius) / 16)), int(floor((position.y - collision_radius) / 16)))
	var cellLeft = navigation_tile_map.get_cell(int(floor((position.x - collision_radius) / 16)), int(floor(position.y / 16)))
	var cellBottomLeft = navigation_tile_map.get_cell(int(floor((position.x - collision_radius) / 16)), int(floor((position.y + collision_radius) / 16)))
	
	# Check if cells / position with enough space around are perfect
	var generate_again = false
	if cell != -1 and cellBottom != -1 and cellBottomRight != -1 and cellRight != -1 and cellTopRight != -1 and cellTop != -1 and cellTopLeft != -1 and cellLeft != -1 and cellBottomLeft != -1:
		var cells = [cell, cellBottom, cellBottomRight, cellRight, cellTopRight, cellTop, cellTopLeft, cellLeft, cellBottomLeft]
		for cell_to_check in cells:
			var shapes = tile_set.tile_get_shapes(cell_to_check)
			if shapes.size() > 0:
				for shape in shapes:
					# If shape on tile is collision then generate again
					if shape["shape"] is RectangleShape2D:
						generate_again = true
	else:
		generate_again = true
	
	if generate_again:
		# Position is blocked by collision, ... - get new one
		return generate_position_in_mob_area(area_info, navigation_tile_map, collision_radius, is_first_spawning)
	else:
		return position

func get_spawn_mobs_list(biome_mobs_count, spawn_mobs_counter):
	var mobs_to_spawn = []
	for _i in range(spawn_mobs_counter):
		var num = rng.randi_range(0, biome_mobs_count - 1)
		mobs_to_spawn.append(num)
	return mobs_to_spawn

func generate_position_near_mob(mob_global_position, min_radius, max_radius, navigation_tile_map, collision_radius):
	# Get random position in circle
	rng.randomize()
	var theta = rng.randi_range(0, 2 * PI)
	var radius = rng.randi_range(min_radius, max_radius)
	var randX = mob_global_position.x + (radius * cos(theta))
	var randY = mob_global_position.y + (radius * sin(theta))
	
	var position = Vector2(randX, randY)
	var tile_set : TileSet = navigation_tile_map.tile_set
	
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
	
	# Check if cells / position with enough space around are perfect
	var generate_again = false
	if cell != -1 and cellBottom != -1 and cellBottomRight != -1 and cellRight != -1 and cellTopRight != -1 and cellTop != -1 and cellTopLeft != -1 and cellLeft != -1 and cellBottomLeft != -1:
		var cells = [cell, cellBottom, cellBottomRight, cellRight, cellTopRight, cellTop, cellTopLeft, cellLeft, cellBottomLeft]
		for cell_to_check in cells:
			var shapes = tile_set.tile_get_shapes(cell_to_check)
			if shapes.size() > 0:
				for shape in shapes:
					# If shape on tile is collision then generate again
					if shape["shape"] is RectangleShape2D:
						generate_again = true
	else:
		generate_again = true
	
	if generate_again:
		# Position is blocked by collision, ... - get new one
		return generate_position_near_mob(mob_global_position, min_radius, max_radius, navigation_tile_map, collision_radius)
	else:
		return position

func generate_position_in_polygon(area_info, is_first_spawn):
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
	# Check if spawn is in camera screen (only on first spawning) -> if it is then generate new position
	if is_first_spawn:
		if not is_position_in_camera_screen(position):
			return position
		else:
			return generate_position_in_polygon(area_info, is_first_spawn)
	else:
		return position


func is_position_in_camera_screen(position):
	var camera : Camera2D = Utils.get_current_player().get_node("Camera2D")
	var canvas_transform = camera.get_canvas_transform()
	var top_left = -canvas_transform.origin / canvas_transform.get_scale()
	var size = camera.get_viewport_rect().end * camera.zoom
	var bottom_right = Vector2(top_left.x + size.x, top_left.y + size.y)
	
	if position.x >= top_left.x and position.y >= top_left.y and position.x <= bottom_right.x and position.y <= bottom_right.y:
		return true
	else:
		return false


func get_players_chunk(map_min_global_pos):
	var player_position = current_player.global_position
	var player_chunk = Vector2.ZERO
	var new_player_position = Vector2.ZERO
	new_player_position.x = abs(map_min_global_pos.x) + player_position.x
	new_player_position.y = abs(map_min_global_pos.y) + player_position.y
	
	player_chunk.x = floor(new_player_position.x / Constants.chunk_size_pixel)
	player_chunk.y = floor(new_player_position.y / Constants.chunk_size_pixel)
	return player_chunk


func get_chunk_from_position(map_min_global_pos, global_position):
	var chunk = Vector2.ZERO
	var new_position = Vector2.ZERO
	new_position.x = abs(map_min_global_pos.x) + global_position.x
	new_position.y = abs(map_min_global_pos.y) + global_position.y
	
	chunk.x = floor(new_position.x / Constants.chunk_size_pixel)
	chunk.y = floor(new_position.y / Constants.chunk_size_pixel)
	return chunk
