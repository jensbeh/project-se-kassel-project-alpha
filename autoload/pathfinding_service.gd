extends Node

var pathfinder_thread = Thread.new()
var mobs_to_update : Dictionary = {}
var enemies_to_update = []
var ambient_mobs_to_update = []
var navigation : Navigation2D
#var ambient_navigation : Navigation2D
#var generate_ambient_mobs_path : bool = false
var can_generate_pathes = false

var astar_node = AStar.new()
var navigation_tilemap = null
var map_size_in_tiles = null
var _point_path = []
var half_cell_size = null
var path_start_position = null
var path_end_position = null


func _ready():
	print("START PATHFINDING_SERVICE")


# Method is called when new scene is loaded with mobs with pathfinding
func init(new_navigation_tilemap : TileMap = null, new_map_size_in_tiles : Vector2 = Vector2.ZERO):
	print("INIT PATHFINDING_SERVICE")
	# Check if thread is active wait to stop
	if pathfinder_thread.is_active():
		clean_thread()
	
#	# Init variables
#	navigation = init_navigation
#	if init_ambient_navigation != null:
#		generate_ambient_mobs_path = true
#		ambient_navigation = init_ambient_navigation
#	else:
#		generate_ambient_mobs_path = false
#		ambient_navigation = null
	
	# Start pathfinder thread
	pathfinder_thread.start(self, "generate_pathes")
	can_generate_pathes = true
	
	
	navigation_tilemap = new_navigation_tilemap
	map_size_in_tiles = new_map_size_in_tiles
	half_cell_size = navigation_tilemap.cell_size / 2
	
	print(navigation_tilemap.get_cell(50,29))
	
	# Init astar
	var obstacles = navigation_tilemap.get_used_cells_by_id(Constants.EMPTY_TILE_ID)
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)


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
	
	print("STOPPED PATHFINDING_SERVICE")


# Method to generate pathes in background
func generate_pathes():
	while can_generate_pathes:
		var enemies = get_tree().get_nodes_in_group("Enemy")
#		var ambient_mobs = get_tree().get_nodes_in_group("Ambient Mob")
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
		
#		if ambient_mobs.size() > 0:
#			ambient_mobs_to_update.clear()
#			for ambient_mob in ambient_mobs:
#				if is_instance_valid(ambient_mob) and ambient_mob.is_inside_tree():
#					if ambient_mob.mob_need_path:
#						ambient_mobs_to_update.append(ambient_mob)
#			if ambient_mobs_to_update.size() > 0:
#				mobs_to_update["ambient_mobs"] = ambient_mobs_to_update
		
		# Generate pathes for mobs
		if mobs_to_update.size() > 0:
			# Generate new pathes and send to mobs
			for mob_key in mobs_to_update.keys():
				if "enemies" == mob_key:
					var enemies_which_need_new_path = mobs_to_update[mob_key]
					for enemy in enemies_which_need_new_path:
						if is_instance_valid(enemy) and enemy.is_inside_tree() and is_instance_valid(navigation) and navigation.is_inside_tree():
							var target_pos = enemy.get_target_position()
							if target_pos == null:
								# If target_pos is null then take last position of enemy
								target_pos = enemy.global_position
							
							var new_path = get_astar_path(enemy.global_position, target_pos)
							
							send_path_to_mob(enemy, new_path)
				
#				elif "ambient_mobs" == mob_key:
#					var ambient_mob_which_need_new_path = mobs_to_update[mob_key]
#					for ambient_mob in ambient_mob_which_need_new_path:
#						if is_instance_valid(ambient_mob) and ambient_mob.is_inside_tree() and is_instance_valid(navigation) and navigation.is_inside_tree():
#							var target_pos = ambient_mob.get_target_position()
#							if target_pos == null:
#								# If target_pos is null then take last position of ambient_mob
#								target_pos = ambient_mob.global_position
#							var new_path = ambient_navigation.get_simple_path(ambient_mob.global_position, target_pos, false)
#							send_path_to_mob(ambient_mob, new_path)


# Method to send new path to mob
func send_path_to_mob(mob, new_path):
	if is_instance_valid(mob) and mob.is_inside_tree(): # Because scene could be change and/or mob is despawned meanwhile
		mob.call_deferred("update_path", new_path)


# Method is called when thread finished
func clean_thread():
	# Wait for thread to finish
	pathfinder_thread.wait_to_finish()




# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles.
func astar_add_walkable_cells(obstacle_list = []):
	var points_array = []
	for y in range(map_size_in_tiles.y):
		for x in range(map_size_in_tiles.x):
			var point = Vector2(x, y)
			if point in obstacle_list:
				continue

			points_array.append(point)
			# The AStar class references points with indices.
			# Using a function to calculate the index from a point's coordinates
			# ensures we always get the same index with the same input point.
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s.
			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array


# Once you added all points to the AStar node, you've got to connect them.
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like.
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...
func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the one to the top, right.
		# left and bottom of it. If it's in the map and not an obstalce.
		# We connect the current point with it.
		var points_relative = PoolVector2Array([
			point + Vector2.RIGHT,
			point + Vector2.LEFT,
			point + Vector2.DOWN,
			point + Vector2.UP,
		])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A.
			# If you set this value to false, it becomes a one-way path.
			# As we loop through all points we can set it to false.
			astar_node.connect_points(point_index, point_relative_index, false)


# Returns the index of the point in the list
func calculate_point_index(point):
	return point.x + map_size_in_tiles.x * point.y


# Checks if point is in map
func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size_in_tiles.x or point.y >= map_size_in_tiles.y


# Returns path for mob
func get_astar_path(mob_start, mob_end):
	path_start_position = navigation_tilemap.world_to_map(mob_start)
	path_end_position = navigation_tilemap.world_to_map(mob_end)
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = navigation_tilemap.map_to_world(Vector2(point.x, point.y)) + half_cell_size
		path_world.append(point_world)
	return path_world


# Generates the path
func _recalculate_path():
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	print(start_point_index)
	# This method gives us an array of points. Note you need the start and
	# end points' indices as input.
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
