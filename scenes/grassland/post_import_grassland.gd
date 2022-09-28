extends Node

var constants = preload("res://autoload/Constants.gd")


var compressed_tilemap = TileMap.new()
var mobs_nav_tilemap = TileMap.new()

var chunk_size = constants.CHUNK_SIZE_TILES # Chunk tiles width/height in tiles
var map_min_pos = Vector2.ZERO # In tiles
var map_max_pos = Vector2.ZERO # In tiles
var map_min_global_pos = Vector2.ZERO # In pixel


# Method to change the scene directly after it is imported by Tiled Map Importer
func post_import(scene):
	print("reimporte " + scene.name + "...")
	
	# Set lights with script to lightsObject
	var lightsObject = scene.find_node("lights")
	if lightsObject != null and lightsObject.get_children().size() > 0:
		for child in lightsObject.get_children():
			if child is Sprite:
				var sprite_positon = child.position
				var custom_light = load("res://scenes/light/CustomLight.tscn").instance()
				custom_light.position = sprite_positon
				custom_light.radius = 64
				var sprite = custom_light.get_node("Sprite")
				sprite.texture = child.texture
				
				# Set custom_light to node/replace existing sprite
				child.replace_by(custom_light, true)
				custom_light.set_owner(scene)
				for child_in_light in custom_light.get_children():
					child_in_light.set_owner(scene)
	
	# Setup map - performace optimisation
	iterate_over_nodes(scene)
	
	# Compress all tilemaps to one - direct before creating navigation and after adding custom nodes with collision on ground
	compress_tilemaps(scene)
	# Add navigation tilemap for mobs
	# Get TileSet from other TileMap because of changing tileset ids "res://assets/map/map_grassland.tmx::5195" -> 5195
	# Also in every TileMap all TileSets are stored
	var dirtLvl0TileMap : TileMap = scene.find_node("dirt lvl0")
	mobs_nav_tilemap = compressed_tilemap
	mobs_nav_tilemap.tile_set = dirtLvl0TileMap.tile_set
	mobs_nav_tilemap.cell_quadrant_size = 1
	mobs_nav_tilemap.cell_y_sort = false
	mobs_nav_tilemap.cell_clip_uv = true
	mobs_nav_tilemap.cell_size = Vector2(16,16)
	mobs_nav_tilemap.name = "NavigationTileMap"
	mobs_nav_tilemap.visible = false
	
	# merge all tilemaps and collisionshapes from "ground" together
	remove_collisionshapes_from_tilemap(mobs_nav_tilemap, scene.find_node("ground"))
	
	# Setup Navigation2D for mobs
	var navigation : Node2D = scene.find_node("navigation")
	var mobs_navigation2d = Navigation2D.new()
	mobs_navigation2d.name = "mobs_navigation2d"
	mobs_navigation2d.visible = false
	navigation.replace_by(mobs_navigation2d, true)
	scene.find_node("mobs_navigation2d").add_child(mobs_nav_tilemap)
	mobs_nav_tilemap.set_owner(scene)
	
	
	
	# Setup Navigation2D for ambient mobs
	var ambient_mobs_navigation : Node2D = scene.find_node("ambientMobs navigation")
	var ambient_mobs_navigation2d = Navigation2D.new()
	ambient_mobs_navigation2d.name = "ambient_mobs_navigation2d"
	ambient_mobs_navigation2d.visible = false
	ambient_mobs_navigation.replace_by(ambient_mobs_navigation2d, true)
	
	# Add navigation polygon for ambient mobs
	var navigation_polygon_instance = NavigationPolygonInstance.new()
	var navigation_polygon = NavigationPolygon.new()
	
	var tile_polygon = PoolVector2Array()
	var rec = compressed_tilemap.get_used_rect()
	
	var topleft = rec.position * 16
	var topright = Vector2(rec.end.x, rec.position.y) * 16
	var bottomleft = Vector2(rec.position.x, rec.end.y) * 16
	var bottomright = Vector2(rec.end.x, rec.end.y) * 16
	tile_polygon.append(topleft)
	tile_polygon.append(topright)
	tile_polygon.append(bottomright)
	tile_polygon.append(bottomleft)
	navigation_polygon.add_outline(tile_polygon)
	navigation_polygon.make_polygons_from_outlines()
	navigation_polygon_instance.navpoly = navigation_polygon
	ambient_mobs_navigation2d.add_child(navigation_polygon_instance)
	navigation_polygon_instance.set_owner(scene)
	
	
	# Setup entitylayer to YSorts
	var entitylayer : Node2D = scene.find_node("entitylayer")
	var ySortEntities = YSort.new()
	ySortEntities.name = entitylayer.name
	entitylayer.replace_by(ySortEntities, true)
	# Setup playerlayer
	var playerlayer : Node2D = scene.find_node("playerlayer")
	var ySortPlayer = YSort.new()
	ySortPlayer.name = playerlayer.name
	playerlayer.replace_by(ySortPlayer, true)
	# Setup mobslayer
	var mobslayer : Node2D = scene.find_node("mobslayer")
	var ySortMobs = YSort.new()
	ySortMobs.name = mobslayer.name
	mobslayer.replace_by(ySortMobs, true)
	
	# Setup NPC pathes
	var npcPathes = scene.find_node("npcPathes")
	var pathes = []
	for child in npcPathes.get_children():
		var path = child.get_child(0)
		var curve = Curve2D.new()
		for point in path.get_polygon():
			curve.add_point(point)
		var newPath = Path2D.new()
		if child.has_meta("is_circle"):
			var meta = child.get_meta("is_circle")
			newPath.set_meta("is_circle", meta)
		child.remove_child(path)
		newPath.set_curve(curve)
		newPath.name = child.name
		newPath.position = child.position
		pathes.append(newPath)
		npcPathes.remove_child(child)
	for path in pathes:
		npcPathes.add_child(path)
		path.set_owner(scene)
	
	# generate chunks -> best at the end
	print("generate chunks...")
	generate_chunks(scene)
	
	# Cleanup scene -> need to be at the end!!
	cleanup_node(scene.find_node("ground"))
	cleanup_node(scene.find_node("higher"))
	print("reimported " + scene.name + "!")
	return scene


# Method to generate chunks in map
func generate_chunks(scene):
	collect_tilemaps(scene.find_node("ground"))
	collect_tilemaps(scene.find_node("higher"))
	
	# Create dublicates to get all tilemaps and objects
	var ground_duplicate = scene.find_node("ground").duplicate()
	var higher_duplicate = scene.find_node("higher").duplicate()
	
	# Map size in tiles
	var map_width = abs(map_min_pos.x) + abs(map_max_pos.x)
	var map_height = abs(map_min_pos.y) + abs(map_max_pos.y)
	var vertical_chunks_count = ceil(map_height / chunk_size) + 1
	var horizontal_chunks_count = ceil(map_width / chunk_size) + 1
	
	# Ground chunks
	var ground_chunks_node = Node2D.new()
	ground_chunks_node.name = "Chunks"
	# Store importent informations in node
	ground_chunks_node.set_meta("vertical_chunks_count", vertical_chunks_count)
	ground_chunks_node.set_meta("horizontal_chunks_count", horizontal_chunks_count)
	ground_chunks_node.set_meta("map_min_global_pos", map_min_global_pos)
	# Add ground_chunks_node to ground
	scene.find_node("ground").add_child(ground_chunks_node)
	ground_chunks_node.set_owner(scene)
	
	# Higher chunks
	var higher_chunks_node = Node2D.new()
	higher_chunks_node.name = "Chunks"
	# Store importent informations in node
	higher_chunks_node.set_meta("vertical_chunks_count", vertical_chunks_count)
	higher_chunks_node.set_meta("horizontal_chunks_count", horizontal_chunks_count)
	higher_chunks_node.set_meta("map_min_global_pos", map_min_global_pos)
	# Add higher_chunks_node to ground
	scene.find_node("higher").add_child(higher_chunks_node)
	higher_chunks_node.set_owner(scene)
	
	
	# Create ground chunks
	for chunk_y in range(vertical_chunks_count):
		for chunk_x in range(horizontal_chunks_count):
			var min_x = map_min_pos.x + chunk_size * chunk_x
			var min_y = map_min_pos.y + chunk_size * chunk_y
			var max_x = (map_min_pos.x + chunk_size * chunk_x) + chunk_size - 1
			var max_y = (map_min_pos.y + chunk_size * chunk_y) + chunk_size - 1
			var chunk_data = {"chunk_x": chunk_x, "chunk_y": chunk_y, "min_x": min_x, "min_y": min_y, "max_x": max_x, "max_y": max_y}

			# Create chunk node
			var chunk_node = Node2D.new()
			chunk_node.name = "Chunk (" + str(chunk_x) + "," + str(chunk_y) + ")"
			chunk_node.visible = false
			ground_chunks_node.add_child(chunk_node)
			chunk_node.set_owner(scene)
			
			# Create chunk with tilemaps and objects
			create_chunk(scene, chunk_data, ground_duplicate, chunk_node)
	
	
	# Create higher chunks
	for chunk_y in range(vertical_chunks_count):
		for chunk_x in range(horizontal_chunks_count):
			var min_x = map_min_pos.x + chunk_size * chunk_x
			var min_y = map_min_pos.y + chunk_size * chunk_y
			var max_x = (map_min_pos.x + chunk_size * chunk_x) + chunk_size - 1
			var max_y = (map_min_pos.y + chunk_size * chunk_y) + chunk_size - 1
			var chunk_data = {"chunk_x": chunk_x, "chunk_y": chunk_y, "min_x": min_x, "min_y": min_y, "max_x": max_x, "max_y": max_y}

			# Create chunk node
			var chunk_node = Node2D.new()
			chunk_node.name = "Chunk (" + str(chunk_x) + "," + str(chunk_y) + ")"
			chunk_node.visible = false
			higher_chunks_node.add_child(chunk_node)
			chunk_node.set_owner(scene)
			
			# Create chunk with tilemaps and objects
			create_chunk(scene, chunk_data, higher_duplicate, chunk_node)


# Method generates a single chunk with all nodes
func create_chunk(scene, chunk_data, ground_duplicate_origin, chunk_node):
	for child in ground_duplicate_origin.get_children():
		if child is TileMap:
			var empty_tilemap = true # To check if tilemap in chunk is empty or not
			var new_tilemap = TileMap.new()
			new_tilemap.name = child.name
			var dirtLvl0TileMap : TileMap = scene.find_node("dirt lvl0")
			new_tilemap.tile_set = dirtLvl0TileMap.tile_set
			new_tilemap.cell_quadrant_size = 1
			new_tilemap.cell_y_sort = false
			new_tilemap.cell_clip_uv = true
			new_tilemap.cell_size = Vector2(16,16)
			for cellPos in child.get_used_cells():
				if cellPos.x >= chunk_data["min_x"] and cellPos.x <= chunk_data["max_x"] and cellPos.y >= chunk_data["min_y"] and cellPos.y <= chunk_data["max_y"]:
					if child.get_cellv(cellPos) != -1:
						empty_tilemap = false
						new_tilemap.set_cell(cellPos.x, cellPos.y, child.get_cellv(cellPos))
			
			# Check if tilemap contains tiles and if it does add tilemap to chunk
			if not empty_tilemap:
				chunk_node.add_child(new_tilemap)
				new_tilemap.set_owner(scene)
		
		elif child is Sprite:
			# Check if child is in this chunk
			var child_position
			if child.region_rect.size.x == 0:
				child_position = Vector2(child.position.x + int(round((child.texture.get_size().x / child.hframes) * child.scale.x - 1)), child.position.y * child.scale.y - 1)
			else:
				var pos_x = child.position.x + int(round(child.region_rect.size.x * child.scale.x - 1))
				var pos_y = child.position.y - 1
				child_position = Vector2(pos_x, pos_y)
			var chunk = get_chunk_from_position(child_position)
			if chunk.x == chunk_data["chunk_x"] and chunk.y == chunk_data["chunk_y"]:
				var sprite = Sprite.new()
				sprite.name = child.name
				sprite.texture = child.texture
				sprite.centered = child.centered
				sprite.offset = child.offset
				sprite.hframes = child.hframes
				sprite.vframes = child.vframes
				sprite.frame = child.frame
				sprite.region_enabled = child.region_enabled
				sprite.region_rect = child.region_rect
				sprite.position = child.position
				sprite.scale = child.scale
				
				# Add parent and child to chunk
				chunk_node.add_child(sprite)
				sprite.set_owner(scene)
				
			else:
				continue
		
		elif child is StaticBody2D:
			# Check if child is in this chunk
			var child_position = child.position + child.get_child(0).shape.extents * 2 - Vector2(1,1)
			var chunk = get_chunk_from_position(child_position)
			if chunk.x == chunk_data["chunk_x"] and chunk.y == chunk_data["chunk_y"]:
				var node = StaticBody2D.new()
				node.name = child.name
				node.position = child.position
				chunk_node.add_child(node)
				node.set_owner(scene)
			else:
				continue
		
		elif child is Area2D:
			# Check if child is in this chunk
			var child_position = child.position + child.get_child(0).shape.extents
			var chunk = get_chunk_from_position(child_position)
			if chunk.x == chunk_data["chunk_x"] and chunk.y == chunk_data["chunk_y"]:
				var node = Area2D.new()
				node.name = child.name
				node.position = child.position
				chunk_node.add_child(node)
				node.set_owner(scene)
			else:
				continue
		
		elif child is CollisionShape2D:
			var node = CollisionShape2D.new()
			node.position = child.position
			chunk_node.add_child(node)
			node.set_owner(scene)
			var shape = RectangleShape2D.new()
			shape.extents = child.shape.extents
			node.shape = shape
		
		elif child is CustomLight:
			# Check if child is in this chunk
			var child_position = Vector2(child.position.x + (child.get_node("Sprite").texture.get_size().x - 1) * child.scale.x, child.position.y)
			var chunk = get_chunk_from_position(child_position)
			if chunk.x == chunk_data["chunk_x"] and chunk.y == chunk_data["chunk_y"]:
				var custom_light = load("res://scenes/light/CustomLight.tscn").instance()
				custom_light.name = child.name
				custom_light.position = child.position
				custom_light.radius = child.radius
				var sprite = custom_light.get_node("Sprite")
				sprite.texture = child.get_node("Sprite").texture
				
				# Set custom_light to node
				chunk_node.add_child(custom_light)
				custom_light.set_owner(scene)
				for child_in_light in custom_light.get_children():
					child_in_light.set_owner(scene)
			continue
		
		else:
			var node = Node2D.new()
			node.name = child.name
			chunk_node.add_child(node)
			node.set_owner(scene)
		
		# Take sub-nodes
		if child.get_child_count() > 0:
			create_chunk(scene, chunk_data, ground_duplicate_origin.get_node(child.name), chunk_node.get_node(child.name))
			if chunk_node.get_node(child.name).get_child_count() == 0:
				chunk_node.remove_child(chunk_node.get_node(child.name))
	
	return chunk_node


# Method to return the chunk coords to the given position
func get_chunk_from_position(global_position):
	var chunk = Vector2.ZERO
	var new_position = Vector2.ZERO
	new_position.x = abs(map_min_global_pos.x) + global_position.x
	new_position.y = abs(map_min_global_pos.y) + global_position.y
	
	chunk.x = floor(new_position.x / constants.chunk_size_pixel)
	chunk.y = floor(new_position.y / constants.chunk_size_pixel)
	return chunk


# Method to cleanup the scene
func remove_tilemaps(node):
	for child in node.get_children():
		if child.get_child_count() > 0:
			remove_tilemaps(child)
		else:
			# Remove all tilemaps excluding navigation tilemaps
			if child is TileMap:
				child.get_parent().remove_child(child)


# Method to cleanup the scene
	# Remove all sub-nodes which are not longer required
func cleanup_node(node):
	# Erase nodes except chunks
	for child in node.get_children():
		if child.name != "Chunks":
			node.remove_child(child)
		else:
			continue


# Method to iterate over all nodes and sets specific properties
func collect_tilemaps(node):
	for child in node.get_children():
		if child.get_child_count() > 0:
			collect_tilemaps(child)
		else:
			if child is TileMap:
				# Get maximum map size in tiles
				var used_cells = child.get_used_cells()
				for cell_pos in used_cells:
					if cell_pos.x < map_min_pos.x:
						map_min_pos.x = cell_pos.x
						var local_position = child.map_to_world(map_min_pos)
						map_min_global_pos.x = local_position.x
					elif cell_pos.x > map_max_pos.x:
						map_max_pos.x = cell_pos.x
					
					if cell_pos.y < map_min_pos.y:
						map_min_pos.y = cell_pos.y
						var local_position = child.map_to_world(map_min_pos)
						map_min_global_pos.y = local_position.y
					elif cell_pos.y > map_max_pos.y:
						map_max_pos.y = cell_pos.y


# Method to iterate over all nodes and sets specific properties
func iterate_over_nodes(node):
	for child in node.get_children():
		if child.get_child_count() > 0:
			iterate_over_nodes(child)
		else:
			if child is TileMap:
				child.cell_quadrant_size = 1
				child.cell_y_sort = false
			
			elif child is CollisionPolygon2D and child.get_parent().get_parent().name == "mobSpawns":
				child.disabled = true
				child.get_parent().set_collision_layer_bit(0, false)
				child.get_parent().set_collision_mask_bit(0, false)
				child.get_parent().monitoring = false
				child.get_parent().monitorable = false
			
			elif child is CollisionShape2D and child.get_parent().get_parent().name == "playerSpawns":
				child.disabled = true
				child.get_parent().set_collision_layer_bit(0, false)
				child.get_parent().set_collision_mask_bit(0, false)
				child.get_parent().monitoring = false
				child.get_parent().monitorable = false
			
			elif child is CollisionShape2D and child.get_parent().get_parent().name == "changeScenes":
				child.get_parent().set_collision_mask_bit(0, false)
				child.get_parent().monitoring = true
				child.get_parent().monitorable = false
			
			elif child is CollisionShape2D and child.get_parent().get_parent().name == "stairs":
				child.get_parent().set_collision_mask_bit(0, false)
				child.get_parent().monitoring = true
				child.get_parent().monitorable = false


# Method to iterate over all nodes in "scene" and compresses all tilemaps to only one
func compress_tilemaps(node):
	for child in node.get_children():
		if child.get_child_count() > 0:
			compress_tilemaps(child)
		else:
			if child is TileMap:
				for cellPos in child.get_used_cells():
					compressed_tilemap.set_cell(cellPos.x, cellPos.y, child.get_cellv(cellPos))


# Method to iterate over all nodes in "ground" and removes all tiles under collisionshapes in tilemap to use map as navigation map
func remove_collisionshapes_from_tilemap(tilemap, node_with_collisionshapes):
	for child in node_with_collisionshapes.get_children():
		if child.get_child_count() > 0:
			remove_collisionshapes_from_tilemap(tilemap, child)
		else:
			if child is CollisionShape2D and child.get_parent() is StaticBody2D:
				var xExtentsFactor = 2
				var yExtentsFactor = 2
					
				for x in (child.shape.extents.x * xExtentsFactor):
					for y in (child.shape.extents.y * yExtentsFactor):
						tilemap.set_cell(int(floor((child.get_parent().position.x + x) / 16)), int(floor((child.get_parent().position.y + y) / 16)), constants.EMPTY_TILE_ID)
