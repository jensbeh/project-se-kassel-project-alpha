extends Node

var pathfinder_thread = Thread.new()
var mobs_to_update : Dictionary = {}
var enemies_to_update = []
var ambient_mobs_to_update = []
var can_generate_pathes = false

var mobs_astar_node = AStar.new()
var ambient_mobs_astar_node = AStar.new()
var mobNavigationTilemap = null
var ambientMobsNavigationTileMap = null
var map_size_in_tiles = null
var map_offset_in_tiles = null
var point_path = []
var half_cell_size = null


func _ready():
	print("START PATHFINDING_SERVICE")


# Method is called when new scene is loaded with mobs with pathfinding
func init(new_mobNavigationTilemap : TileMap = null, new_ambientMobsNavigationTileMap : TileMap = null, new_map_size_in_tiles : Vector2 = Vector2.ZERO, new_map_min_global_pos = null):
	print("INIT PATHFINDING_SERVICE")
	# Check if thread is active wait to stop
	if pathfinder_thread.is_active():
		clean_thread()
	
	# Init variables
	mobNavigationTilemap = new_mobNavigationTilemap
	print(mobNavigationTilemap.get_cell(50,29))
	ambientMobsNavigationTileMap = new_ambientMobsNavigationTileMap
	
	map_size_in_tiles = new_map_size_in_tiles
	map_offset_in_tiles = new_map_min_global_pos / Constants.TILE_SIZE
	half_cell_size = mobNavigationTilemap.cell_size / 2
	
	# Start pathfinder thread
	pathfinder_thread.start(self, "generate_pathes")
	can_generate_pathes = true
	
	# Init AStar
	# Mobs
	var mobs_obstacles = mobNavigationTilemap.get_used_cells_by_id(Constants.PSEUDO_OBSTACLE_TILE_ID)
	var mobs_walkable_cells_list = astar_add_walkable_cells_for_mobs(mobs_obstacles)
	astar_connect_walkable_cells_for_mobs(mobs_walkable_cells_list)
	# Ambient mobs
	var ambient_mobs_obstacles = ambientMobsNavigationTileMap.get_used_cells_by_id(Constants.PSEUDO_OBSTACLE_TILE_ID)
	var ambient_mobs_walkable_cells_list = astar_add_walkable_cells_for_ambient_mobs(ambient_mobs_obstacles)
	astar_connect_walkable_cells_for_ambient_mobs(ambient_mobs_walkable_cells_list)
	
#	print("map_size_in_tiles: " + str(map_size_in_tiles))
#	print("map_offset_in_tiles: " + str(map_offset_in_tiles))
#	print("new_map_min_global_pos: " + str(new_map_min_global_pos))
#	print("new_map_min_global_pos/tilesize: " + str(new_map_min_global_pos/Constants.TILE_SIZE))


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
func astar_add_walkable_cells_for_mobs(obstacle_list = []):
	var points_array = []
	for y in range(map_offset_in_tiles.y, map_offset_in_tiles.y + map_size_in_tiles.y + 1):
		for x in range(map_offset_in_tiles.x, map_offset_in_tiles.x + map_size_in_tiles.x + 1):
			var point = Vector2(x, y)
			if point in obstacle_list:
				continue
			
			points_array.append(point)
			# The AStar class references points with indices.
			# Using a function to calculate the index from a point's coordinates
			# ensures to always get the same index with the same input point
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s.
			mobs_astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array


# Loops through all cells within the map's bounds and
# adds all points to the ambient_mobs_astar_node, except the obstacles.
func astar_add_walkable_cells_for_ambient_mobs(obstacle_list = []):
	var points_array = []
	for y in range(map_offset_in_tiles.y, map_offset_in_tiles.y + map_size_in_tiles.y + 1):
		for x in range(map_offset_in_tiles.x, map_offset_in_tiles.x + map_size_in_tiles.x + 1):
			var point = Vector2(x, y)
			if point in obstacle_list:
				continue
			
			points_array.append(point)
			# The AStar class references points with indices.
			# Using a function to calculate the index from a point's coordinates
			# ensures to always get the same index with the same input point
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s.
			ambient_mobs_astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array


# After added all points to the mobs_astar_node, connect them
func astar_connect_walkable_cells_for_mobs(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		
		# For every cell in the map, we check the one to the top, right, 
		# left and bottom of it. If it's in the map and not an obstalce -> connect it
		var points_relative = PoolVector2Array([
			point + Vector2.RIGHT,
			point + Vector2.LEFT,
			point + Vector2.DOWN,
			point + Vector2.UP,
		])
		
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			# Check point_relative
			if is_outside_map_bounds(point_relative):
				continue
			if not mobs_astar_node.has_point(point_relative_index):
				continue
			
			# Connect points if everything is okay
			mobs_astar_node.connect_points(point_index, point_relative_index, false) # False means it is one-way / not bilateral


# After added all points to the ambient_mobs_astar_node, connect them
func astar_connect_walkable_cells_for_ambient_mobs(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		
		# For every cell in the map, we check the one to the top, right, 
		# left and bottom of it. If it's in the map and not an obstalce -> connect it
		var points_relative = PoolVector2Array([
			point + Vector2.RIGHT,
			point + Vector2.LEFT,
			point + Vector2.DOWN,
			point + Vector2.UP,
		])
		
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			# Check point_relative
			if is_outside_map_bounds(point_relative):
				continue
			if not ambient_mobs_astar_node.has_point(point_relative_index):
				continue
			
			# Connect points if everything is okay
			ambient_mobs_astar_node.connect_points(point_index, point_relative_index, false) # False means it is one-way / not bilateral


# Method calculates the index of the point in astar_nodes - INPUT: Tilecoords like (-272, -144) or (128, 64)
func calculate_point_index(point):
	# Points are from (-272, -144) to (128, 64)
#	if point.x > 127 and point.y > 63:
#		print(point)
#	if point.x < -271 and point.y < -143:
#		print(point)
	
	# Make them to (0, 0) to (400, 208)
	point -= map_offset_in_tiles
#	if point.x > 399 and point.y > 207:
#		print(point)
#	if point.x < 1 and point.y < 1:
#		print(point)
	
	return point.x + map_size_in_tiles.x * point.y


# Method to check if point is inside map like (-272, -144) or (128, 64)
func is_outside_map_bounds(point):
	return ((point.x < map_offset_in_tiles.x and point.y < map_offset_in_tiles.y) and (point.x > (map_offset_in_tiles.x + map_size_in_tiles.x) and point.y > (map_offset_in_tiles.y + map_size_in_tiles.y)))


# Generates and returns path for the given positions
func get_mob_astar_path(mob_start, mob_end):
	# Get position in map and get point index in mobs_astar_node
	var path_start_tile_position = mobNavigationTilemap.world_to_map(mob_start)
	var path_end_tile_position = mobNavigationTilemap.world_to_map(mob_end)
	var start_point_index = calculate_point_index(path_start_tile_position)
	var end_point_index = calculate_point_index(path_end_tile_position)
#	print("mob_start: " + str(mob_start))
#	print("mob_end: " + str(mob_end))
#	print("path_start_tile_position: " + str(path_start_tile_position))
#	print("path_end_tile_position: " + str(path_end_tile_position))
#	print("start_point_index: " + str(start_point_index))
#	print("end_point_index: " + str(end_point_index))
	
	
	# Get the path as an array of points from mobs_astar_node
	point_path = mobs_astar_node.get_point_path(start_point_index, end_point_index)
	# Remove the position in index 0 because this is the starting cell
	point_path.remove(0)
	
	# Convert point to map positions
	var path_world = []
	for point in point_path:
		var point_world = mobNavigationTilemap.map_to_world(Vector2(point.x, point.y)) + half_cell_size
		path_world.append(point_world)
	
	# Return path
	return path_world


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
