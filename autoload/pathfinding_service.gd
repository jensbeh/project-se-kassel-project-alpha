extends Node

var pathfinder_thread = Thread.new()
var mobs_to_update : Dictionary = {}
var enemies_to_update = []
var ambient_mobs_to_update = []
var can_generate_pathes = false

var mobs_astar_node = AStar.new()
var ambient_mobs_astar_node = AStar.new()
var mobNavigationTilemap : TileMap = null
var ambientMobsNavigationTileMap : TileMap = null
var map_size_in_tiles = null
var map_min_global_pos = null
var map_offset_in_tiles = null
var point_path = []
var half_cell_size = null
var points
var points_tile
var points_horizontal_per_tile
var points_vertical_per_tile
var points_horizontal_in_map
var points_vertical_in_map


func _ready():
	print("START PATHFINDING_SERVICE")


# Method is called when new scene is loaded with mobs with pathfinding
func init(map_name = "", _node2d = null, new_mobNavigationTilemap : TileMap = null, new_ambientMobsNavigationTileMap : TileMap = null, new_map_size_in_tiles : Vector2 = Vector2.ZERO, new_map_min_global_pos = null):
	print("INIT PATHFINDING_SERVICE")
	# Check if thread is active wait to stop
	if pathfinder_thread.is_active():
		clean_thread()
	
	# Init variables
	mobNavigationTilemap = new_mobNavigationTilemap
	ambientMobsNavigationTileMap = new_ambientMobsNavigationTileMap
	
	map_size_in_tiles = new_map_size_in_tiles
	map_min_global_pos = new_map_min_global_pos
	map_offset_in_tiles = map_min_global_pos / Constants.TILE_SIZE
	half_cell_size = mobNavigationTilemap.cell_size / 2
	
	points = 3
	points_tile = points * points
	points_horizontal_per_tile = 3
	points_vertical_per_tile = 3
	
	# Init AStar
	var astar_nodes_dics = load_astar_file(map_name)
	# Mobs
	astar_add_walkable_cells_for_mobs(astar_nodes_dics["mobs"])
	astar_connect_walkable_cells_for_mobs(astar_nodes_dics["mobs"])
	# Ambient mobs
	if ambientMobsNavigationTileMap != null:
		astar_add_walkable_cells_for_ambient_mobs(astar_nodes_dics["ambient_mobs"])
		astar_connect_walkable_cells_for_ambient_mobs(astar_nodes_dics["ambient_mobs"])
	
#	print("map_size_in_tiles: " + str(map_size_in_tiles))
#	print("map_offset_in_tiles: " + str(map_offset_in_tiles))
#	print("new_map_min_global_pos: " + str(new_map_min_global_pos))
#	print("new_map_min_global_pos/tilesize: " + str(new_map_min_global_pos/Constants.TILE_SIZE))
	
	# Start pathfinder thread
	pathfinder_thread.start(self, "generate_pathes")
	can_generate_pathes = true
	
	# Init visualizer
#	node2d.visualize(mobs_astar_node)


# Method to load the astar points and connections from file -> file generated through reimport
func load_astar_file(map_name):
	# Check if directory is existing
	var dir_game_pathfinding = Directory.new()
	if dir_game_pathfinding.open(Constants.SAVE_GAME_PATHFINDING_PATH) == OK:
		dir_game_pathfinding.list_dir_begin()
		var file_name = dir_game_pathfinding.get_next()
		while file_name != "":
			if map_name in file_name:
				var astar_load = File.new()
				astar_load.open(Constants.SAVE_GAME_PATHFINDING_PATH + file_name, File.READ)
				var dic = astar_load.get_var(true)
				astar_load.close()
				return dic
			
			file_name = dir_game_pathfinding.get_next()
	
	else:
		printerr("An error occurred when trying to access the PATHFINDING PATH.")


# Method to stop the pathfinder to change map
func stop():
	# Reset variables
	call_deferred("cleanup")


# Method to cleanup the pathfinder
func cleanup():
	# Check if thread is active wait to stop
	can_generate_pathes = false
	if pathfinder_thread.is_active():
		clean_thread()
	
	# Reset variables
	mobs_to_update.clear()
	enemies_to_update.clear()
	ambient_mobs_to_update.clear()
	mobNavigationTilemap = null
	ambientMobsNavigationTileMap = null
	map_size_in_tiles = null
	half_cell_size = null
	mobs_astar_node.clear()
	ambient_mobs_astar_node.clear()
	
	print("STOPPED PATHFINDING_SERVICE")


# Method to generate pathes in background
func generate_pathes():
	while can_generate_pathes:
		var enemies = get_tree().get_nodes_in_group("Enemy")
		var ambient_mobs = get_tree().get_nodes_in_group("Ambient Mob")
		if mobs_to_update.size() > 0:
			mobs_to_update.clear()
		
		if enemies.size() > 0:
			enemies_to_update.clear()
			for enemy in enemies:
				if is_instance_valid(enemy) and enemy.is_inside_tree():
					if enemy.mob_need_path:
						enemies_to_update.append(enemy)
			if enemies_to_update.size() > 0:
				mobs_to_update["enemies"] = enemies_to_update
		
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
						if is_instance_valid(enemy) and enemy.is_inside_tree() and is_instance_valid(mobNavigationTilemap) and mobNavigationTilemap.is_inside_tree():
							var target_pos = enemy.get_target_position()
							if target_pos == null:
								# If target_pos is null then take last position of enemy
								target_pos = enemy.global_position
#							print("generate for: " + enemy.name)
							var new_path = get_mob_astar_path(enemy.global_position, target_pos)
#							print("new_path: " + str(new_path))
							send_path_to_mob(enemy, new_path)
				
				elif "ambient_mobs" == mob_key:
					var ambient_mob_which_need_new_path = mobs_to_update[mob_key]
					for ambient_mob in ambient_mob_which_need_new_path:
						if is_instance_valid(ambient_mob) and ambient_mob.is_inside_tree() and is_instance_valid(ambientMobsNavigationTileMap) and ambientMobsNavigationTileMap.is_inside_tree():
							var target_pos = ambient_mob.get_target_position()
							if target_pos == null:
								# If target_pos is null then take last position of ambient_mob
								target_pos = ambient_mob.global_position
							
#							print("generate for: " + ambient_mob.name)
							var new_path = get_ambient_mob_astar_path(ambient_mob.global_position, target_pos)
							send_path_to_mob(ambient_mob, new_path)


# Method to send new path to mob
func send_path_to_mob(mob, new_path):
	if is_instance_valid(mob) and mob.is_inside_tree(): # Because scene could be change and/or mob is despawned meanwhile
		mob.call_deferred("update_path", new_path)


# Method is called when thread finished
func clean_thread():
	# Wait for thread to finish
	pathfinder_thread.wait_to_finish()


# Loops through all cells within the map's bounds and
# adds all points to the mobs_astar_node, except the obstacles.
func astar_add_walkable_cells_for_mobs(astar_node_dic):
	for point in astar_node_dic.keys():
		var point_index = astar_node_dic[point]["point_index"]
		mobs_astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))


# Loops through all cells within the map's bounds and
# adds all points to the ambient_mobs_astar_node, except the obstacles.
func astar_add_walkable_cells_for_ambient_mobs(astar_node_dic):
	for point in astar_node_dic.keys():
		var point_index = astar_node_dic[point]["point_index"]
		ambient_mobs_astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))


# After added all points to the mobs_astar_node, connect them
func astar_connect_walkable_cells_for_mobs(astar_node_dic):
	for point in astar_node_dic.keys():
		var point_index = astar_node_dic[point]["point_index"]
		var point_connections = astar_node_dic[point]["connections"]
		for point_connection in point_connections:
			mobs_astar_node.connect_points(point_index, point_connection, false) # False means it is one-way / not bilateral


# After added all points to the ambient_mobs_astar_node, connect them
func astar_connect_walkable_cells_for_ambient_mobs(astar_node_dic):
	for point in astar_node_dic.keys():
		var point_index = astar_node_dic[point]["point_index"]
		var point_connections = astar_node_dic[point]["connections"]
		for point_connection in point_connections:
			ambient_mobs_astar_node.connect_points(point_index, point_connection, false) # False means it is one-way / not bilateral


# Method calculates the index of the point in astar_nodes - INPUT: Tilecoords like (-272, -144) or (128, 64)
func calculate_point_index(point):
	# Points are from (-272, -144) to (128, 64)
	# Make them to (0, 0) to (400, 208)
	point -= map_offset_in_tiles * 2
	
	return point.x + map_size_in_tiles.x * 2 * point.y


# Generates and returns path for the given positions
func get_mob_astar_path(mob_start, mob_end):
	# Get position in map and get point index in mobs_astar_node
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
	if not mobs_astar_node.has_point(start_point_index):
		start_point_index = mobs_astar_node.get_closest_point(Vector3(path_start_tile_position.x, path_start_tile_position.y, 0), false)
	
	# Check if end position is valid / reachable - else take nearest & valid point to the invalid point
	if not mobs_astar_node.has_point(end_point_index):
		end_point_index = mobs_astar_node.get_closest_point(Vector3(path_end_tile_position.x, path_end_tile_position.y, 0), false)
	
	# Get the path as an array of points from mobs_astar_node
	point_path = mobs_astar_node.get_point_path(start_point_index, end_point_index)
	# Remove the position in index 0 because this is the starting cell
	point_path.remove(0)
	
	# Convert point to map positions
	var path_world = []
	for point in point_path:
		var point_world = point_coords_world(Vector2(point.x, point.y))
		path_world.append(point_world)
	
	# Return path
	return path_world


# Method to generate global_position to tile_coord
func world_to_tile_coords(global_position : Vector2):
	var point = Vector2.ZERO
	point.x = floor(global_position.x / (Constants.TILE_SIZE / (points_horizontal_per_tile - 1)))
	point.y = floor(global_position.y / (Constants.TILE_SIZE / (points_horizontal_per_tile - 1)))
	
	return point


# Method to generate tile_coord to global_position
func point_coords_world(tile_coords : Vector2):
	var global_position = Vector2.ZERO
	global_position.x = tile_coords.x * (Constants.TILE_SIZE / (points_horizontal_per_tile - 1))
	global_position.y = tile_coords.y * (Constants.TILE_SIZE / (points_horizontal_per_tile - 1))
	
	return global_position


# Generates and returns path for the given positions
func get_ambient_mob_astar_path(mob_start, mob_end):
	# Get position in map and get point index in ambient_mobs_astar_node
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
	
	# Get the path as an array of points from ambient_mobs_astar_node
	point_path = ambient_mobs_astar_node.get_point_path(start_point_index, end_point_index)
	# Remove the position in index 0 because this is the starting cell
	point_path.remove(0)
	
	# Convert point to map positions
	var path_world = []
	for point in point_path:
		var point_world = ambientMobsNavigationTileMap.map_to_world(Vector2(point.x, point.y)) + half_cell_size
		path_world.append(point_world)
	
	# Return path
	return path_world
