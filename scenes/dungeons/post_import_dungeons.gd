extends Node

var compressed_tilemap = TileMap.new()
var mobs_nav_tilemap = TileMap.new()

# Method to change the scene directly after it is imported by Tiled Map Importer
func post_import(scene):
	print("reimporte " + scene.name + "...")
	
	# Setup map - performace optimisation
	iterate_over_nodes(scene)
	
	# Compress all tilemaps to one
	compress_tilemaps(scene)
	
	# Add navigation tilemap for mobs
	# Get TileSet from other TileMap because of changing tileset ids "res://assets/map/map_grassland.tmx::5195" -> 5195
	# Also in every TileMap all TileSets are stored
	var groundTileMap : TileMap = scene.find_node("ground")
	mobs_nav_tilemap = compressed_tilemap
	mobs_nav_tilemap.tile_set = groundTileMap.tile_set
	mobs_nav_tilemap.cell_quadrant_size = 1
	mobs_nav_tilemap.cell_y_sort = false
	mobs_nav_tilemap.cell_clip_uv = true
	mobs_nav_tilemap.cell_size = Vector2(16,16)
	mobs_nav_tilemap.name = "NavigationTileMap"
	
	
	# merge all tilemaps and collisionshapes from "groundlayer" together
	remove_collisionshapes_from_tilemap(mobs_nav_tilemap, scene.find_node("groundlayer"))
	
	# Setup Navigation2D for mobs
	var navigation : Node2D = scene.find_node("navigation")
	var mobs_navigation2d = Navigation2D.new()
	mobs_navigation2d.name = "mobs_navigation2d"
	navigation.replace_by(mobs_navigation2d, true)
	scene.find_node("mobs_navigation2d").add_child(mobs_nav_tilemap)
	mobs_nav_tilemap.set_owner(scene)
	
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
	
	print("reimported " + scene.name + "!")
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
						tilemap.set_cell(int(floor((child.get_parent().position.x + x) / 16)), int(floor((child.get_parent().position.y + y) / 16)), -1)
