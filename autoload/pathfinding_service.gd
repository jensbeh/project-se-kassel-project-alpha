extends Node

var pathfinder_thread = Thread.new()
var mobs_to_update : Dictionary = {}
var enemies_to_update = []
var bosses_to_update = []
var ambient_mobs_to_update = []
var mobs_waiting = []
var can_generate_pathes = false
var should_generate_pathes = false

var ambientMobsNavigationTileMap : TileMap = null
var map_size_in_tiles = null
var map_min_global_pos = null
var map_offset_in_tiles = null
var half_cell_size = null
var map_name
var astar_nodes_cache = {}
var astar2DVisualizerNode = null
var mutex = Mutex.new()
var mobs_with_new_position : Dictionary = {}

func _ready():
	print("START PATHFINDING_SERVICE")


# Method to preload the astar nodes
func preload_astars():
	print("preload_astars")
	
	# Load astar points and connections
	var astar_nodes_file_dics : Dictionary = load_astar_files()
	
	for astar_dic_key in astar_nodes_file_dics.keys():
		map_name = astar_dic_key
		
		if "grassland" in map_name:
			# Create new AStars and store them to use later again
			if not astar_nodes_cache.has(map_name):
				astar_nodes_cache[map_name] = {
									"mobs" : null,
									"bosses" : null,
									"ambient_mobs" : null,
									"dynamic_obstacles" : {}
									}
			
			# Mobs
			astar_nodes_cache[map_name]["mobs"] = CustomAstar.new()
			astar_add_walkable_cells_for_mobs(astar_nodes_file_dics[map_name]["mobs"]["points"])
			astar_connect_walkable_cells_for_mobs(astar_nodes_file_dics[map_name]["mobs"]["points"])
			
			# Bosses
			if astar_nodes_file_dics[map_name]["bosses"]["points"].size() > 0:
				astar_nodes_cache[map_name]["bosses"] = CustomAstar.new()
				astar_add_walkable_cells_for_bosses(astar_nodes_file_dics[map_name]["bosses"]["points"])
				astar_connect_walkable_cells_for_bosses(astar_nodes_file_dics[map_name]["bosses"]["points"])
			
			# Ambient mobs
			if astar_nodes_file_dics[map_name]["ambient_mobs"]["points"].size() > 0:
				astar_nodes_cache[map_name]["ambient_mobs"] = CustomAstar.new()
				astar_add_walkable_cells_for_ambient_mobs(astar_nodes_file_dics[map_name]["ambient_mobs"]["points"])
				astar_connect_walkable_cells_for_ambient_mobs(astar_nodes_file_dics[map_name]["ambient_mobs"]["points"])
			
			print("LOADED \"" + str(map_name) + "\"")
	
	map_name = ""
	astar_nodes_file_dics.clear()
	
	print("preload_astars DONE")


# Method is called when new scene is loaded with mobs with pathfinding
func init(new_map_name = "", new_astar2DVisualizerNode = null, new_ambientMobsNavigationTileMap : TileMap = null, new_map_size_in_tiles : Vector2 = Vector2.ZERO, new_map_min_global_pos = null):
	print("INIT PATHFINDING_SERVICE")
	# Check if thread is active wait to stop
	if pathfinder_thread.is_active():
		clean_thread()
	
	# Init variables
	map_name = new_map_name
	ambientMobsNavigationTileMap = new_ambientMobsNavigationTileMap
	
	map_size_in_tiles = new_map_size_in_tiles
	map_min_global_pos = new_map_min_global_pos
	map_offset_in_tiles = map_min_global_pos / Constants.TILE_SIZE
	half_cell_size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE) / 2
	
#	print("map_size_in_tiles: " + str(map_size_in_tiles))
#	print("map_offset_in_tiles: " + str(map_offset_in_tiles))
#	print("new_map_min_global_pos: " + str(new_map_min_global_pos))
#	print("new_map_min_global_pos/tilesize: " + str(new_map_min_global_pos/Constants.TILE_SIZE))
	
	# Start pathfinder thread
	pathfinder_thread.start(self, "generate_pathes")
	can_generate_pathes = true
	
	# Init visualizer
	astar2DVisualizerNode = new_astar2DVisualizerNode
	if astar2DVisualizerNode != null:
		astar2DVisualizerNode.call_deferred("visualize", astar_nodes_cache[map_name]["bosses"])


# Method to start pathfinding service (call after init)
func start():
	should_generate_pathes = true


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
		printerr("An error occurred when trying to access the PATHFINDING PATH.")


# Method to stop the pathfinder to change map
func stop():
	# Delete variables
	enemies_to_update = null
	bosses_to_update = null
	ambient_mobs_to_update = null
	can_generate_pathes = null
	should_generate_pathes = null
	
	map_name = null
	astar_nodes_cache.clear()
	astar_nodes_cache = null
	
	print("STOPPED PATHFINDING_SERVICE")


# Method to cleanup the pathfinder
func cleanup():
	# Check if thread is active wait to stop
	can_generate_pathes = false
	should_generate_pathes = false
	
	if pathfinder_thread.is_active():
		clean_thread()
	
	# Clean variables
	mobs_to_update.clear()
	enemies_to_update.clear()
	bosses_to_update.clear()
	ambient_mobs_to_update.clear()
	ambientMobsNavigationTileMap = null
	map_size_in_tiles = null
	map_min_global_pos = null
	map_offset_in_tiles = null
	half_cell_size = null
	astar2DVisualizerNode = null
	
	# Clean dynamic obstacles
	if not astar_nodes_cache[map_name]["dynamic_obstacles"].empty():
		for obstacle in astar_nodes_cache[map_name]["dynamic_obstacles"].keys():
			for point_index in astar_nodes_cache[map_name]["dynamic_obstacles"][obstacle]:
				astar_nodes_cache[map_name]["mobs"].set_point_disabled(point_index, false)
		astar_nodes_cache[map_name]["dynamic_obstacles"].clear()
	
	map_name = ""
	
	print("CLEANED PATHFINDING_SERVICE")


# Method to generate pathes in background
func generate_pathes():
	while can_generate_pathes:
		if should_generate_pathes == true:
			
			var enemies = get_tree().get_nodes_in_group("Enemy")
			var bosses = get_tree().get_nodes_in_group("Boss")
			var ambient_mobs = get_tree().get_nodes_in_group("Ambient Mob")
			if mobs_to_update.size() > 0:
				mobs_to_update.clear()
			
			if enemies.size() > 0:
				enemies_to_update.clear()
				for enemy in enemies:
					if is_instance_valid(enemy) and enemy.is_inside_tree():
						if enemy.mob_need_path and not mobs_waiting.has(enemy):
							enemies_to_update.append(enemy)
				if enemies_to_update.size() > 0:
					mobs_to_update["enemies"] = enemies_to_update
			
			if bosses.size() > 0:
				bosses_to_update.clear()
				for boss in bosses:
					if is_instance_valid(boss) and boss.is_inside_tree():
						if boss.mob_need_path:
							bosses_to_update.append(boss)
				if bosses_to_update.size() > 0:
					mobs_to_update["bosses"] = bosses_to_update
			
			if ambient_mobs.size() > 0:
				ambient_mobs_to_update.clear()
				for ambient_mob in ambient_mobs:
					if is_instance_valid(ambient_mob) and ambient_mob.is_inside_tree():
						if ambient_mob.mob_need_path:
							ambient_mobs_to_update.append(ambient_mob)
				if ambient_mobs_to_update.size() > 0:
					mobs_to_update["ambient_mobs"] = ambient_mobs_to_update
			
			
			# Generate pathes for mobs
			if mobs_to_update.size() > 0:
				# Generate new pathes and send to mobs
				for mob_key in mobs_to_update.keys():
					if "enemies" == mob_key:
						var enemies_which_need_new_path = mobs_to_update[mob_key]
						for enemy in enemies_which_need_new_path:
							
							if is_instance_valid(enemy) and enemy.is_inside_tree():
								enemy.get_target_position()
								mutex.lock()
								mobs_waiting.append(enemy)
								mutex.unlock()
			
			if mobs_with_new_position.size() > 0:
				mutex.lock()
#				print("mobs_with_new_position.keys(): " + str(mobs_with_new_position.keys()))
				for mob in mobs_with_new_position.keys():
#					print("mob: " + str(mob))
					var new_path = get_mob_astar_path(mob.global_position, mobs_with_new_position[mob])
					call_deferred("send_path_to_mob", mob, new_path)
					var _was_present = mobs_with_new_position.erase(mob)
#					print("MOB READY")
#				print("")
#				print("")
				mutex.unlock()
			
#								var target_pos = enemy.get_target_position()
#
#								if target_pos == null:
#									# If target_pos is null then take last position of enemy
#									target_pos = enemy.global_position
#
#								var mutex = Mutex.new()
#								mutex.lock()
#								var new_path = get_mob_astar_path(enemy.global_position, target_pos)
#								mutex.unlock()
#								call_deferred("send_path_to_mob", enemy, new_path)
					
#					elif "bosses" == mob_key:
#						var bosses_which_need_new_path = mobs_to_update[mob_key]
#						for boss in bosses_which_need_new_path:
#
#							if is_instance_valid(boss) and boss.is_inside_tree():
#
#								var target_pos = boss.get_target_position()
#
#								if target_pos == null:
#									# If target_pos is null then take last position of boss
#									target_pos = boss.global_position
#
#								var new_path = get_boss_astar_path(boss.global_position, target_pos)
#
#								call_deferred("send_path_to_mob", boss, new_path)
#
#					elif "ambient_mobs" == mob_key:
#						var ambient_mob_which_need_new_path = mobs_to_update[mob_key]
#						for ambient_mob in ambient_mob_which_need_new_path:
#							if is_instance_valid(ambient_mob) and ambient_mob.is_inside_tree() and is_instance_valid(ambientMobsNavigationTileMap) and ambientMobsNavigationTileMap.is_inside_tree():
#								var target_pos = ambient_mob.get_target_position()
#								if target_pos == null:
#									# If target_pos is null then take last position of ambient_mob
#									target_pos = ambient_mob.global_position
#
#								var new_path = get_ambient_mob_astar_path(ambient_mob.global_position, target_pos)
#								call_deferred("send_path_to_mob", ambient_mob, new_path)


# Method to send new path to mob
func send_path_to_mob(mob, new_path):
#	print("send_path_to_mob: " +  str(mob))
	if is_instance_valid(mob) and mob.is_inside_tree(): # Because scene could be change and/or mob is despawned meanwhile
		mob.call_deferred("update_path", new_path)
#		print("mobs_waiting1: ")
		mutex.lock()
		mobs_waiting.remove(mobs_waiting.find(mob))
		mutex.unlock()
#		print("mobs_waiting2: ")
#	print("finished")
#	print("")


# Method is called when thread finished
func clean_thread():
	# Wait for thread to finish
	pathfinder_thread.wait_to_finish()


# Loops through all cells within the map's bounds and
# adds all points to the astar_nodes_cache[map_name]["mobs"], except the obstacles.
func astar_add_walkable_cells_for_mobs(astar_node_points_dic):
	for point in astar_node_points_dic.keys():
		var point_index = astar_node_points_dic[point]["point_index"]
		astar_nodes_cache[map_name]["mobs"].add_point(point_index, Vector3(point.x, point.y, 0.0))


# Loops through all cells within the map's bounds and
# adds all points to the astar_nodes_cache[map_name]["mobs"], except the obstacles.
func astar_add_walkable_cells_for_bosses(astar_node_points_dic):
	for point in astar_node_points_dic.keys():
		var point_index = astar_node_points_dic[point]["point_index"]
		astar_nodes_cache[map_name]["bosses"].add_point(point_index, Vector3(point.x, point.y, 0.0))


# Loops through all cells within the map's bounds and
# adds all points to the astar_nodes_cache[map_name]["ambient_mobs"], except the obstacles.
func astar_add_walkable_cells_for_ambient_mobs(astar_node_points_dic):
	for point in astar_node_points_dic.keys():
		var point_index = astar_node_points_dic[point]["point_index"]
		astar_nodes_cache[map_name]["ambient_mobs"].add_point(point_index, Vector3(point.x, point.y, 0.0))


# After added all points to the astar_nodes_cache[map_name]["mobs"], connect them
func astar_connect_walkable_cells_for_mobs(astar_node_points_dic):
	for point in astar_node_points_dic.keys():
		var point_index = astar_node_points_dic[point]["point_index"]
		var point_connections = astar_node_points_dic[point]["connections"]
		for point_connection in point_connections:
			astar_nodes_cache[map_name]["mobs"].connect_points(point_index, point_connection, false) # False means it is one-way / not bilateral



# After added all points to the astar_nodes_cache[map_name]["mobs"], connect them
func astar_connect_walkable_cells_for_bosses(astar_node_points_dic):
	for point in astar_node_points_dic.keys():
		var point_index = astar_node_points_dic[point]["point_index"]
		var point_connections = astar_node_points_dic[point]["connections"]
		for point_connection in point_connections:
			astar_nodes_cache[map_name]["bosses"].connect_points(point_index, point_connection, false) # False means it is one-way / not bilateral


# After added all points to the astar_nodes_cache[map_name]["ambient_mobs"], connect them
func astar_connect_walkable_cells_for_ambient_mobs(astar_node_points_dic):
	for point in astar_node_points_dic.keys():
		var point_index = astar_node_points_dic[point]["point_index"]
		var point_connections = astar_node_points_dic[point]["connections"]
		for point_connection in point_connections:
			astar_nodes_cache[map_name]["ambient_mobs"].connect_points(point_index, point_connection, false) # False means it is one-way / not bilateral


# Method calculates the index of the point in astar_nodes - INPUT: Tilecoords like (-272, -144) or (128, 64)
func calculate_point_index(point):
	# Points are from (-272, -144) to (128, 64)
	# Make them to (0, 0) to (400, 208)
	point -= map_offset_in_tiles * 2
	
	return point.x + map_size_in_tiles.x * 2 * point.y


# Generates and returns path for the given positions
func get_mob_astar_path(mob_start, mob_end):
	var time_start = OS.get_system_time_msecs()
	var time_now = 0
	var dic = {}
	
	# Get position in map and get point index in astar_nodes_cache[map_name]["mobs"]
	var path_start_tile_position = world_to_tile_coords(mob_start)
	var path_end_tile_position = world_to_tile_coords(mob_end)
	var start_point_index = calculate_point_index(path_start_tile_position)
	var end_point_index = calculate_point_index(path_end_tile_position)
#	print("mob_start: " + str(mob_start))
#	print("mob_end: " + str(mob_end))
#	print("path_start_tile_position: " + str(path_start_tile_position))
#	print("path_end_tile_position: " + str(path_end_tile_position))
#	print("start_point_index: " + str(start_point_index))
#	print("end_point_index: " + str(end_point_index))
#	print("")
#	print("")
	
	# Check if start_position is valid - else take nearest & valid point to the invalid point
	if not astar_nodes_cache[map_name]["mobs"].has_point(start_point_index):
		start_point_index = astar_nodes_cache[map_name]["mobs"].get_closest_point(Vector3(path_start_tile_position.x, path_start_tile_position.y, 0), false)
	
	# Check if end position is valid / reachable - else take nearest & valid point to the invalid point
	if not astar_nodes_cache[map_name]["mobs"].has_point(end_point_index):
		end_point_index = astar_nodes_cache[map_name]["mobs"].get_closest_point(Vector3(path_end_tile_position.x, path_end_tile_position.y, 0), false)
	
#	time_now = OS.get_system_time_msecs()
#	var time_elapsed = time_now - time_start
#	dic["start"] = time_elapsed
#	time_start = OS.get_system_time_msecs()
	
	# Check if point is disabled -> take nearest & enabled point to the disabled point
	if astar_nodes_cache[map_name]["mobs"].has_point(start_point_index) and astar_nodes_cache[map_name]["mobs"].is_point_disabled(start_point_index):
		start_point_index = astar_nodes_cache[map_name]["mobs"].get_closest_point(Vector3(path_start_tile_position.x, path_start_tile_position.y, 0), false)
	if astar_nodes_cache[map_name]["mobs"].has_point(end_point_index) and astar_nodes_cache[map_name]["mobs"].is_point_disabled(end_point_index):
		end_point_index = astar_nodes_cache[map_name]["mobs"].get_closest_point(Vector3(path_end_tile_position.x, path_end_tile_position.y, 0), false)
	
	# Get the path as an array of points from astar_nodes_cache[map_name]["mobs"]
	var point_path = astar_nodes_cache[map_name]["mobs"].get_point_path(start_point_index, end_point_index) # !!! TAKES LONG TIME!!!!!!!! 73217 57269
	
	
	# Get time to calculate path
	time_now = OS.get_system_time_msecs()
	var time_elapsed = time_now - time_start
	dic["get_point_path"] = time_elapsed
#	time_start = OS.get_system_time_msecs()
	
	if point_path.size() != 0:
		# Remove the position in index 0 because this is the starting cell
		point_path.remove(0)

		
		# Convert point to map positions
		var path_world = []
		for point in point_path:
			var point_world = point_coords_world(Vector2(point.x, point.y))
			path_world.append(point_world)
		
	#	time_now = OS.get_system_time_msecs()
	#	time_elapsed = time_now - time_start
	#	dic["rest"] = time_elapsed
		
		if dic["get_point_path"] > 200:
			print("-----------------> HERE: " + str(dic))
			print("mob_start: " + str(mob_start))
			print("mob_end: " + str(mob_end))
			print("path_start_tile_position: " + str(path_start_tile_position))
			print("path_end_tile_position: " + str(path_end_tile_position))
			print("start_point_index: " + str(start_point_index))
			print("end_point_index: " + str(end_point_index))
			print("map_min_global_pos: " + str(map_min_global_pos))
			print("map_offset_in_tiles: " + str(map_offset_in_tiles))
			print("map_size_in_tiles: " + str(map_size_in_tiles))
			print("")
			print("")
		
		# Return path
		return path_world
	
	else:
		printerr("ERROR - \"get_mob_astar_path\" NO PATH AVAILABLE")
		return []


# Generates and returns path for the given positions
func get_boss_astar_path(boss_start, boss_end):
	# Get position in map and get point index in astar_nodes_cache[map_name]["bosses"]
	var path_start_tile_position = world_to_tile_coords(boss_start)
	var path_end_tile_position = world_to_tile_coords(boss_end)
	var start_point_index = calculate_point_index(path_start_tile_position)
	var end_point_index = calculate_point_index(path_end_tile_position)
	
	# Check if start_position is valid - else take nearest & valid point to the invalid point
	if not astar_nodes_cache[map_name]["bosses"].has_point(start_point_index):
		start_point_index = astar_nodes_cache[map_name]["bosses"].get_closest_point(Vector3(path_start_tile_position.x, path_start_tile_position.y, 0), false)
	
	# Check if end position is valid / reachable - else take nearest & valid point to the invalid point
	if not astar_nodes_cache[map_name]["bosses"].has_point(end_point_index):
		end_point_index = astar_nodes_cache[map_name]["bosses"].get_closest_point(Vector3(path_end_tile_position.x, path_end_tile_position.y, 0), false)
	
	# Check if point is disabled -> take nearest & enabled point to the disabled point
	if astar_nodes_cache[map_name]["bosses"].has_point(start_point_index) and astar_nodes_cache[map_name]["bosses"].is_point_disabled(start_point_index):
		start_point_index = astar_nodes_cache[map_name]["bosses"].get_closest_point(Vector3(path_start_tile_position.x, path_start_tile_position.y, 0), false)
	if astar_nodes_cache[map_name]["bosses"].has_point(end_point_index) and astar_nodes_cache[map_name]["bosses"].is_point_disabled(end_point_index):
		end_point_index = astar_nodes_cache[map_name]["bosses"].get_closest_point(Vector3(path_end_tile_position.x, path_end_tile_position.y, 0), false)
	
	# Get the path as an array of points from astar_nodes_cache[map_name]["bosses"]
	var point_path = astar_nodes_cache[map_name]["bosses"].get_point_path(start_point_index, end_point_index) # !!! TAKES LONG TIME!!!!!!!! 73217 57269
	
	if point_path.size() != 0:
		# Remove the position in index 0 because this is the starting cell
		point_path.remove(0)
		
		# Convert point to map positions
		var path_world = []
		for point in point_path:
			var point_world = point_coords_world(Vector2(point.x, point.y))
			path_world.append(point_world)
		
		# Return path
		return path_world
	
	else:
		printerr("ERROR - \"get_boss_astar_path\" NO PATH AVAILABLE")
		return []

# Method to generate global_position to tile_coord
func world_to_tile_coords(global_position : Vector2):
	var point = Vector2.ZERO
	point.x = floor(global_position.x / (float(Constants.TILE_SIZE) / (Constants.POINTS_HORIZONTAL_PER_TILE - 1)))
	point.y = floor(global_position.y / (float(Constants.TILE_SIZE) / (Constants.POINTS_VERTICAL_PER_TILE - 1)))
	
	return point


# Method to generate tile_coord to global_position
func point_coords_world(tile_coords : Vector2):
	var global_position = Vector2.ZERO
	global_position.x = tile_coords.x * (float(Constants.TILE_SIZE) / (Constants.POINTS_HORIZONTAL_PER_TILE - 1))
	global_position.y = tile_coords.y * (float(Constants.TILE_SIZE) / (Constants.POINTS_VERTICAL_PER_TILE - 1))
	
	return global_position


# Generates and returns path for the given positions
func get_ambient_mob_astar_path(mob_start, mob_end):
	# Get position in map and get point index in astar_nodes_cache[map_name]["ambient_mobs"]
	var path_start_tile_position = ambientMobsNavigationTileMap.world_to_map(mob_start)
	var path_end_tile_position = ambientMobsNavigationTileMap.world_to_map(mob_end)
	var start_point_index = calculate_point_index(path_start_tile_position)
	var end_point_index = calculate_point_index(path_end_tile_position)
#	print("mob_start: " + str(mob_start))
#	print("mob_end: " + str(mob_end))
#	print("path_start_tile_position: " + str(path_start_tile_position))
#	print("path_end_tile_position: " + str(path_end_tile_position))
#	print("start_point_index: " + str(start_point_index))
#	print("end_point_index: " + str(end_point_index))
	
	
	# Check if start_position is valid - else take nearest & valid point to the invalid point
	if not astar_nodes_cache[map_name]["ambient_mobs"].has_point(start_point_index):
		start_point_index = astar_nodes_cache[map_name]["ambient_mobs"].get_closest_point(Vector3(path_start_tile_position.x, path_start_tile_position.y, 0), false)
	
	# Check if end position is valid / reachable - else take nearest & valid point to the invalid point
	if not astar_nodes_cache[map_name]["ambient_mobs"].has_point(end_point_index):
		end_point_index = astar_nodes_cache[map_name]["ambient_mobs"].get_closest_point(Vector3(path_end_tile_position.x, path_end_tile_position.y, 0), false)
	
	
	# Get the path as an array of points from astar_nodes_cache[map_name]["ambient_mobs"]
	var point_path = astar_nodes_cache[map_name]["ambient_mobs"].get_point_path(start_point_index, end_point_index)
		
	if point_path.size() != 0:
		# Remove the position in index 0 because this is the starting cell
		point_path.remove(0)
		
		# Convert point to map positions
		var path_world = []
		for point in point_path:
			var point_world = ambientMobsNavigationTileMap.map_to_world(Vector2(point.x, point.y)) + half_cell_size
			path_world.append(point_world)
		
		# Return path
		return path_world
	
	else:
		printerr("ERROR - \"get_ambient_mob_astar_path\" NO PATH AVAILABLE")
		return []


# Method to disable points within the collisionshape FOR MOBS
func add_dynamic_obstacle(collisionshape_node : CollisionShape2D, position):
	astar_nodes_cache[map_name]["dynamic_obstacles"][collisionshape_node.get_instance_id()] = []
	var xExtentsFactor = 2
	var yExtentsFactor = 2
	var size_x = ceil(collisionshape_node.shape.extents.x * xExtentsFactor)
	var size_y = ceil(collisionshape_node.shape.extents.y * yExtentsFactor)
	
	# Top left point
	var top_left_position = position
	var top_left_point = world_to_tile_coords(top_left_position)
	var top_left_point_index = calculate_point_index(top_left_point)
	if astar_nodes_cache[map_name]["mobs"].has_point(top_left_point_index):
		astar_nodes_cache[map_name]["dynamic_obstacles"][collisionshape_node.get_instance_id()].append(top_left_point_index)
		astar_nodes_cache[map_name]["mobs"].set_point_disabled(top_left_point_index, true)
	
	# Bottom right point
	var bottom_right_position = Vector2(position.x + size_x + Constants.POINT_SIZE_IN_PIXEL_PER_TILE, position.y + size_y + Constants.POINT_SIZE_IN_PIXEL_PER_TILE) # Add here POINT_SIZE_IN_PIXEL_PER_TILE because point is top left of point area. Extend because of bottom right
	var bottom_right_point = world_to_tile_coords(bottom_right_position)
	var bottom_right_point_index = calculate_point_index(bottom_right_point)
	if astar_nodes_cache[map_name]["mobs"].has_point(bottom_right_point_index):
		astar_nodes_cache[map_name]["dynamic_obstacles"][collisionshape_node.get_instance_id()].append(bottom_right_point_index)
		astar_nodes_cache[map_name]["mobs"].set_point_disabled(bottom_right_point_index, true)
	
	# Get all points between top_left_point and bottom_right_point
	var horizontal_point_span = bottom_right_point.x - top_left_point.x + 1
	var vertical_point_span = bottom_right_point.y - top_left_point.y + 1
	for x in horizontal_point_span:
		for y in vertical_point_span:
			var current_point = top_left_point + Vector2(x, y)
			var current_point_index = calculate_point_index(current_point)
			if astar_nodes_cache[map_name]["mobs"].has_point(current_point_index) and not astar_nodes_cache[map_name]["dynamic_obstacles"][collisionshape_node.get_instance_id()].has(current_point_index):
				astar_nodes_cache[map_name]["dynamic_obstacles"][collisionshape_node.get_instance_id()].append(current_point_index)
				astar_nodes_cache[map_name]["mobs"].set_point_disabled(current_point_index, true)
	
#	# Round up to avoid wrong shape size
#	var range_x = ceil(collisionshape_node.shape.extents.x * xExtentsFactor)
#	var range_y = ceil(collisionshape_node.shape.extents.y * yExtentsFactor)
#	print(position)
#	print(position + collisionshape_node.shape.extents * 2)
#	for x in (range_x):
#		for y in (range_y):
#			# Check all positions inside shape
#			var current_position = Vector2(position.x + x, position.y + y)
#			var point = world_to_tile_coords(current_position)
#			var point_index = calculate_point_index(point)
#			print("current_position: " + str(current_position))
#			print("point: " + str(point))
#			if astar_nodes_cache[map_name]["mobs"].has_point(point_index) and not astar_nodes_cache[map_name]["dynamic_obstacles"][collisionshape_node.get_instance_id()].has(point_index):
#				astar_nodes_cache[map_name]["dynamic_obstacles"][collisionshape_node.get_instance_id()].append(point_index)
#				astar_nodes_cache[map_name]["mobs"].set_point_disabled(point_index, true)
#				print("disabled normal: " + str(point))
#
#			# Check all positions at the bottom/right of the shape and add extra points there
#			var extra_safety_point_offset = Vector2.ZERO
#			# Add safety border if right or/and bottom
#			if x == range_x - 1:
#				extra_safety_point_offset.x = extra_safety_point_offset.x + 1
#			if y == range_y - 1:
#				extra_safety_point_offset.y = extra_safety_point_offset.y + 1
#			# Check new point
#			if extra_safety_point_offset != Vector2.ZERO:
#				point = world_to_tile_coords(current_position) + extra_safety_point_offset
#				point_index = calculate_point_index(point)
#				if astar_nodes_cache[map_name]["mobs"].has_point(point_index) and not astar_nodes_cache[map_name]["dynamic_obstacles"][collisionshape_node.get_instance_id()].has(point_index):
#					astar_nodes_cache[map_name]["dynamic_obstacles"][collisionshape_node.get_instance_id()].append(point_index)
#					astar_nodes_cache[map_name]["mobs"].set_point_disabled(point_index, true)
#					print("disabled safety: " + str(point))
	
	# Update obstacles visual
#	if astar2DVisualizerNode != null:
#		astar2DVisualizerNode.call_deferred("update_disabled_points")


func has_boss_path(start_pos, end_pos):
	# Get position in map and get point index in astar_nodes_cache[map_name]["bosses"]
	var path_start_tile_position = world_to_tile_coords(start_pos)
	var path_end_tile_position = world_to_tile_coords(end_pos)
	var start_point_index = calculate_point_index(path_start_tile_position)
	var end_point_index = calculate_point_index(path_end_tile_position)
	
	# Check if start_position is valid - else take nearest & valid point to the invalid point
	if not astar_nodes_cache[map_name]["bosses"].has_point(start_point_index):
		start_point_index = astar_nodes_cache[map_name]["bosses"].get_closest_point(Vector3(path_start_tile_position.x, path_start_tile_position.y, 0), false)
	
	# Check if end position is valid / reachable - else take nearest & valid point to the invalid point
	if not astar_nodes_cache[map_name]["bosses"].has_point(end_point_index):
		end_point_index = astar_nodes_cache[map_name]["bosses"].get_closest_point(Vector3(path_end_tile_position.x, path_end_tile_position.y, 0), false)
	
	# Check if point is disabled -> take nearest & enabled point to the disabled point
	if astar_nodes_cache[map_name]["bosses"].has_point(start_point_index) and astar_nodes_cache[map_name]["bosses"].is_point_disabled(start_point_index):
		start_point_index = astar_nodes_cache[map_name]["bosses"].get_closest_point(Vector3(path_start_tile_position.x, path_start_tile_position.y, 0), false)
	if astar_nodes_cache[map_name]["bosses"].has_point(end_point_index) and astar_nodes_cache[map_name]["bosses"].is_point_disabled(end_point_index):
		end_point_index = astar_nodes_cache[map_name]["bosses"].get_closest_point(Vector3(path_end_tile_position.x, path_end_tile_position.y, 0), false)
	
	# Get the path as an array of points from astar_nodes_cache[map_name]["bosses"]
	var point_path = astar_nodes_cache[map_name]["bosses"].get_point_path(start_point_index, end_point_index) # !!! TAKES LONG TIME!!!!!!!! 73217 57269
	
	return point_path.size() > 0


func got_position(mob, position):
#	print("got_position")
	
	mutex.lock()
	mobs_with_new_position[mob] = position
	mutex.unlock()
