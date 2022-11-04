extends Node

# Variables
var current_player : KinematicBody2D = null # Must be used in game scenes
var language = ""
var rng : RandomNumberGenerator = RandomNumberGenerator.new()


func _ready():
	pass


# Method to update language in game
func update_language():
	# Update language in player ui
	Utils.get_player_ui().update_language()


# Returns the player in the loaded current_scene
func get_player():
	return get_node("/root/Main/Game/Viewport/SceneManager/CurrentScene").get_children().back().find_node("Player")


# Sets a new current_player instance (firstly done when enter the game - not available in the menu)
func set_current_player(new_current_player: KinematicBody2D):
	current_player = new_current_player


# Returns the current_player instance
func get_current_player():
	return current_player


# Returns the scene_manager instance
func get_scene_manager():
	return get_node("/root/Main/Game/Viewport/SceneManager")


# Sets the current language
func set_language(lang):
	language = lang


# Returns the current language
func get_language():
	return language


# Returns the scene_manager instance
func get_main():
	return get_node("/root/Main")


# Method to return the UI node
func get_ui():
	return get_node("/root/Main/UI")


# Method to return the minimap node
func get_minimap():
	return get_ui().get_node("/root/Main/UI/Minimap")


# Method to return the game menu node
func get_game_menu():
	return get_ui().get_node_or_null("GameMenu")


# Method to remove the game menu node
func remove_game_menu():
	return get_ui().remove_child(get_game_menu())


# Method to return the character interface node
func get_character_interface():
	return get_ui().get_node_or_null("CharacterInterface")


# Method to remove the character interface node
func remove_character_interface():
	return get_ui().remove_child(get_character_interface())


# Method to return the death screen node
func get_death_screen():
	return get_ui().get_node_or_null("DeathScreen")


# Method to remove the death screen node
func remove_death_screen():
	return get_ui().remove_child(get_death_screen())


# Method to return the control notes node
func get_control_notes():
	return get_ui().get_node_or_null("ControlNotes")


# Method to return the player ui node
func get_player_ui():
	return get_ui().get_node_or_null("PlayerUI")


# Method to return the trade inventory node
func get_trade_inventory():
	return get_ui().get_node_or_null("TradeInventory")


# Method to return the inventory node
func get_inventory():
	return get_ui().get_node_or_null("Inventory")


# Method to return the hotbar node
func get_hotbar():
	return get_player_ui().get_node_or_null("Hotbar")


# Method to return LootPanel node
func get_loot_panel():
	return get_ui().get_node_or_null("LootPanel")


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
#		print("Menu state")
		return Constants.SceneType.MENU
	
	# House
	elif Constants.CAMP_BUILDING_FOLDER in transition_data.get_scene_path() or Constants.GRASSLAND_BUILDING_FOLDER in transition_data.get_scene_path():
#		print("House state")
		return Constants.SceneType.HOUSE
	
	# Camp
	elif Constants.CAMP_FOLDER in transition_data.get_scene_path():
#		print("Camp state")
		return Constants.SceneType.CAMP
	
	# Grassland
	elif Constants.GRASSLAND_FOLDER in transition_data.get_scene_path():
#		print("Grassland state")
		return Constants.SceneType.GRASSLAND
	
	# Dungeons
	elif Constants.DUNGEONS_FOLDER in transition_data.get_scene_path():
#		print("Dungeons state")
		return Constants.SceneType.DUNGEON


# Method generates spawning area with trianges and returns them
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


# Method to generate a valid position in a mob area
func generate_position_in_mob_area(scene_type, area_info, navigation_tile_map : TileMap, collision_radius, is_first_spawning, lootLayer, spawn_loot_tile_distance = 1) -> Vector2:
	var tile_set : TileSet = navigation_tile_map.tile_set
	var position : Vector2
	
	var generate_position = true
	while(generate_position):
		position = generate_position_in_polygon(area_info, is_first_spawning)
		
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
		var obstacle_tile_id
		if scene_type == Constants.SceneType.GRASSLAND:
			obstacle_tile_id = Constants.PSEUDO_OBSTACLE_TILE_ID
		elif scene_type == Constants.SceneType.DUNGEON:
			obstacle_tile_id = Constants.PSEUDO_OBSTACLE_TILE_ID_DUNGEONS
		else:
			printerr("ERROR: Invalid scene type in generate_position_in_mob_area for \"obstacle_tile_id\"")
		
		if cell != obstacle_tile_id and cell != Constants.INVALID_TILE_ID \
		 and cellBottom != obstacle_tile_id and cellBottom != Constants.INVALID_TILE_ID \
		 and cellBottomRight != obstacle_tile_id and cellBottomRight != Constants.INVALID_TILE_ID \
		 and cellRight != obstacle_tile_id and cellRight != Constants.INVALID_TILE_ID \
		 and cellTopRight != obstacle_tile_id and cellTopRight != Constants.INVALID_TILE_ID \
		 and cellTop != obstacle_tile_id and cellTop != Constants.INVALID_TILE_ID \
		 and cellTopLeft != obstacle_tile_id and cellTopLeft != Constants.INVALID_TILE_ID \
		 and cellLeft != obstacle_tile_id and cellLeft != Constants.INVALID_TILE_ID \
		 and cellBottomLeft != obstacle_tile_id and cellBottomLeft != Constants.INVALID_TILE_ID :
			# Cells are valid -> check if they contain collision
			var cells = [cell, cellBottom, cellBottomRight, cellRight, cellTopRight, cellTop, cellTopLeft, cellLeft, cellBottomLeft]
			for cell_to_check in cells:
				var shapes = tile_set.tile_get_shapes(cell_to_check)
				if shapes.size() > 0:
					for shape in shapes:
						# If shape on tile is collision then generate again
						if shape["shape"] is RectangleShape2D:
							generate_again = true
		
		# One of these cells is obstacles/invalid
		else:
			generate_again = true
		
		# Before return check positions of dynamic obstacles
		if not generate_again and lootLayer != null and is_node_valid(lootLayer):
			# Loot & treasures
			for loot in lootLayer.get_children():
				if "treasure" in loot.name:
					# Check position if inside treasure
					var size_x = ceil(loot.get_node("StaticBody/CollisionShape2D").shape.extents.x * 2)
					var size_y = ceil(loot.get_node("StaticBody/CollisionShape2D").shape.extents.y * 2)
					var max_position_loot = Vector2(loot.global_position.x + size_x, loot.global_position.y + size_y)
					
					var extra_safe_space = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE) * spawn_loot_tile_distance
					
					var top_left = loot.global_position - extra_safe_space
					var bottom_right = max_position_loot + extra_safe_space
					
					if position.x >= top_left.x and position.y >= top_left.y \
					 and position.x <= bottom_right.x and position.y <= bottom_right.y:
						# Inside of treasure area
						generate_again = true
#						printerr("ERROR: generate_position_in_mob_area - Inside of treasure area")
				
				elif not "Loot" in loot.name:
					printerr("ERROR: generate_position_in_mob_area - Loot & treasures -> " + str(loot.name))
		
		
		if not generate_again:
			# Position is NOT blocked by collision, ... - get new one
			generate_position = false
#		else:
#			print("generate_again - generate_position_in_mob_area")
	
	return position


# Method to return random mob list as spawning list to spawning area
func get_spawn_mobs_list(biome_mobs_count, spawn_mobs_counter):
	var mobs_to_spawn = []
	rng.randomize()
	for _i in range(spawn_mobs_counter):
		var num = rng.randi_range(0, biome_mobs_count - 1)
		mobs_to_spawn.append(num)
	return mobs_to_spawn


# Method generates a valid position in a radius around the mob
func generate_position_near_mob(scene_type, mob_global_position, min_radius, max_radius, navigation_tile_map, collision_radius):
	var tile_set : TileSet = navigation_tile_map.tile_set
	var position : Vector2
	
	# Get random position in circle
	rng.randomize()
	var theta = rng.randf_range(0.0, 2.0 * PI)
	var radius = rng.randf_range(float(min_radius), float(max_radius))
	var randX = mob_global_position.x + (radius * cos(theta))
	var randY = mob_global_position.y + (radius * sin(theta))
	
	position = Vector2(randX, randY)
	
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
	var obstacle_tile_id
	if scene_type == Constants.SceneType.GRASSLAND:
		obstacle_tile_id = Constants.PSEUDO_OBSTACLE_TILE_ID
	elif scene_type == Constants.SceneType.DUNGEON:
		obstacle_tile_id = Constants.PSEUDO_OBSTACLE_TILE_ID_DUNGEONS
	else:
		printerr("ERROR: Invalid scene type in generate_position_near_mob for \"obstacle_tile_id\"")
		
	if cell != obstacle_tile_id and cell != Constants.INVALID_TILE_ID \
	 and cellBottom != obstacle_tile_id and cellBottom != Constants.INVALID_TILE_ID \
	 and cellBottomRight != obstacle_tile_id and cellBottomRight != Constants.INVALID_TILE_ID \
	 and cellRight != obstacle_tile_id and cellRight != Constants.INVALID_TILE_ID \
	 and cellTopRight != obstacle_tile_id and cellTopRight != Constants.INVALID_TILE_ID \
	 and cellTop != obstacle_tile_id and cellTop != Constants.INVALID_TILE_ID \
	 and cellTopLeft != obstacle_tile_id and cellTopLeft != Constants.INVALID_TILE_ID \
	 and cellLeft != obstacle_tile_id and cellLeft != Constants.INVALID_TILE_ID \
	 and cellBottomLeft != obstacle_tile_id and cellBottomLeft != Constants.INVALID_TILE_ID :
		# Cells are valid -> check if they contain collision
		var cells = [cell, cellBottom, cellBottomRight, cellRight, cellTopRight, cellTop, cellTopLeft, cellLeft, cellBottomLeft]
		for cell_to_check in cells:
			var shapes = tile_set.tile_get_shapes(cell_to_check)
			if shapes.size() > 0:
				for shape in shapes:
					# If shape on tile is collision then generate again
					if shape["shape"] is RectangleShape2D:
						generate_again = true
	
	# One of these cells is obstacles/invalid
	else:
		generate_again = true
	
	return {
		"generate_again": generate_again,
		"position": position
		}


# Method generates a position in a polygon and checks if the position is in camera screen
func generate_position_in_polygon(area_info, is_first_spawn):
	var complete_polygon_area = area_info[0] # complete_polygon_area
	var position : Vector2
	
	var counter_in_camera_screen = 0
	var generate_position = true
	while(generate_position):
		randomize()
		# Get weighted random triangle
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
		
		position = Vector2(randX, randY)
		# Check if spawn is in camera screen (only on first spawning) -> if it is then generate new position
		if is_first_spawn:
			if not is_position_in_camera_screen(position):
				# Position NOT in camera screen -> take postion
				generate_position = false
			else:
				# Position IN camera screen -> generate new postion
				counter_in_camera_screen += 1
				
				# Max regenerations when inside camera screen
				if counter_in_camera_screen >= 3:
					# Check if position is not to near to player
					if position.distance_to(Utils.get_current_player().global_position) >= 125:
						generate_position = false
		
		else:
			generate_position = false
	
	return position


# Method to check is given position is in camera screen
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


# Method to return the players chunk coords with players position
func get_players_chunk(map_min_global_pos):
	if is_node_valid(current_player):
		var player_position = current_player.global_position
		var player_chunk = Vector2.ZERO
		var new_player_position = Vector2.ZERO
		new_player_position.x = abs(map_min_global_pos.x) + player_position.x
		new_player_position.y = abs(map_min_global_pos.y) + player_position.y
		
		player_chunk.x = floor(new_player_position.x / Constants.chunk_size_pixel)
		player_chunk.y = floor(new_player_position.y / Constants.chunk_size_pixel)
		return player_chunk


# Method to return the chunk coords to the given position
func get_chunk_from_position(map_min_global_pos, global_position):
	var chunk = Vector2.ZERO
	var new_position = Vector2.ZERO
	new_position.x = abs(map_min_global_pos.x) + global_position.x
	new_position.y = abs(map_min_global_pos.y) + global_position.y
	
	chunk.x = floor(new_position.x / Constants.chunk_size_pixel)
	chunk.y = floor(new_position.y / Constants.chunk_size_pixel)
	return chunk


# Method to generate random vector2 position in rectangle Area2D
func get_random_position_in_rectangle_area(rectangle_area: Area2D) -> Vector2:
	var rectangle_shape = rectangle_area.get_child(0).shape
	var top_left = rectangle_area.position
	var bottom_right = top_left + (rectangle_shape.extents * 2)
	rng.randomize()
	var rand_x = rng.randi_range(top_left.x, bottom_right.x)
	var rand_y = rng.randi_range(top_left.y, bottom_right.y)
	var position = Vector2(rand_x, rand_y)
	return position


# Method to choose random boss instance path
func get_random_boss_instance_path():
	return Constants.BossPathes[randi() % Constants.BossPathes.size()]


# Method to preload game -> called ONLY! from start screen
func preload_game():
	print("GAME: Preloading...")
	# Measure time
	var time_start = OS.get_system_time_msecs()
	var time_now = 0
	
	# Load here everything which needs to be preloaded
	# Load AStars
	PathfindingService.preload_astars()
	
	
	# Calculate needed time
	time_now = OS.get_system_time_msecs()
	var time_elapsed = time_now - time_start
	
	print("GAME: Preload finished! (" + str(time_elapsed / 1000.0) + " sec)")


# Method to check if node is valid and still present
func is_node_valid(node):
	if is_instance_valid(node) and node != null and not node.is_queued_for_deletion() and node.is_inside_tree():
		return true
	else:
		return false


# Method to pause and resume game
func pause_game(should_pause):
	# Pause
	if should_pause:
		print("GAME: Pause")
		
		# Pause cooldown timer
		Utils.get_hotbar().pause_cooldown()
		
		# Pause time
		DayNightCycle.pause_time(true)
		
		# Pause player input
		Utils.get_ui().player_input(false)
	
	# Resume
	else:
		print("GAME: Resume")
		
		# Resume cooldown timer
		Utils.get_hotbar().resume_cooldown()
		
		# Resume time
		DayNightCycle.pause_time(false)
		
		# Resume player input
		Utils.get_ui().player_input(true)


# Method to start the stop of the game
func stop_game():
	print("GAME: Stopping...")
	
	# Start fade to black transition in main.gd
	get_main().start_close_game_transition()


func save_game():
	get_main().get_node("LoadingScreen/Save").set_text(tr("SAVED"))
	get_main().get_node("LoadingScreen/SaveScreen").play("Saved")
	var data = get_current_player().get_data()
	data.scene_transition = get_scene_manager().current_transition_data.get_scene_path()
	data.position = var2str(get_current_player().position)
	data.view_direction = var2str(get_current_player().direction)
	data.time = DayNightCycle.current_time
	# map informations
	data.show_map = get_ui().show_map
	data.has_map = get_ui().has_map
	save_player_data(data)
	PlayerData.save_inventory()


func save_player_data(player_data):
	var save_game = File.new()
	save_game.open(Constants.SAVE_CHARACTER_PATH + player_data.id + "/" + player_data.name + ".json", File.WRITE)
	save_game.store_line(to_json(player_data))
	save_game.close()
