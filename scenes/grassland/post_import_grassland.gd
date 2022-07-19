extends Node


var navTilemap = TileMap.new()


# Method to change the scene directly after it is imported by Tiled Map Importer
func post_import(scene):
	print("reimported " + scene.name)
	
	# Setup map - performace optimisation
	iterate_over_nodes(scene)
	
	# Add navigation tilemap
	navTilemap.tile_set = load("res://assets/map/map_grassland.tmx::5194")
	navTilemap.cell_quadrant_size = 1
	navTilemap.cell_y_sort = false
	navTilemap.cell_clip_uv = true
	navTilemap.cell_size = Vector2(16,16)
	
	# merge all tilemaps and collisionshapes from "ground" together
	iterate_over_collisionshapes_and_tilemaps(scene.find_node("ground"))
	
	# Setup Navigation2D
	var navigation : Node2D = scene.find_node("navigation")
	var navigation2d = Navigation2D.new()
	navigation2d.name = "navigation"
	navigation.replace_by(navigation2d, true)
	scene.find_node("navigation").add_child(navTilemap)
	navTilemap.set_owner(scene)
	
	
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
	
	# Set lights with script to lightsObject
	var lightsObject = scene.find_node("lights")
	if lightsObject != null and lightsObject.get_children().size() > 0:
		for child in lightsObject.get_children():
			if child is Sprite:
				var sprite_positon = child.position
				var custom_light = load("res://scenes/light/CustomLight.tscn").instance()
				custom_light.radius = 64
				custom_light.position = Vector2(sprite_positon.x + 8, sprite_positon.y - 8)
				
				lightsObject.add_child(custom_light)
				custom_light.set_owner(scene)
				
	return scene

# Method to iterate over all nodes and sets specific properties
func iterate_over_nodes(node):
	for child in node.get_children():
		if child.get_child_count() > 0:
			iterate_over_nodes(child)
		else:
			if child is TileMap:
				child.cell_quadrant_size = 1
				child.cell_y_sort = false

# Method to iterate over all nodes in "ground" and removes all tiles under collisionshapes in tilemap to use map as navigation map
func iterate_over_collisionshapes_and_tilemaps(node):
	for child in node.get_children():
		if child.get_child_count() > 0:
			iterate_over_collisionshapes_and_tilemaps(child)
		else:
			if child is TileMap:
				print(child.name)
				for cellPos in child.get_used_cells():
					navTilemap.set_cell(cellPos.x, cellPos.y, child.get_cellv(cellPos))
			
			elif child is CollisionShape2D and child.get_parent() is StaticBody2D:
				var xExtentsFactor = 2
				var yExtentsFactor = 2
					
				for x in (child.shape.extents.x * xExtentsFactor):
					for y in (child.shape.extents.y * yExtentsFactor):
						navTilemap.set_cell(int(floor((child.get_parent().position.x + x) / 16)), int(floor((child.get_parent().position.y + y) / 16)), -1)
