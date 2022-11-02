extends Node

const CUSTOM_LIGHT = preload("res://scenes/light/CustomLight.tscn")


# Method to change the scene directly after it is imported by Tiled Map Importer
func post_import(scene):
	print("POST_IMPORT_BUILDINGS: Reimporte " + scene.name + "...")
	
	# Set lights with script to lightsObject
	var lightsObject = scene.find_node("lights")
	if lightsObject != null and lightsObject.get_children().size() > 0:
		for child in lightsObject.get_children():
			if child is Sprite:
				var sprite_positon = child.position
				var custom_light = CUSTOM_LIGHT.instance()
				custom_light.position = sprite_positon
				custom_light.radius = 64
				var sprite = custom_light.get_node("Sprite")
				sprite.texture = child.texture
				
				# Set custom_light to node/replace existing sprite
				child.replace_by(custom_light, true)
				custom_light.set_owner(scene)
				for child_in_light in custom_light.get_children():
					child_in_light.set_owner(scene)
	
	
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
	# Setup npclayer
	var npclayer : Node2D = scene.find_node("npclayer")
	var ySortNPCS = YSort.new()
	ySortNPCS.name = npclayer.name
	npclayer.replace_by(ySortNPCS, true)
	
	
	# Setup map - performace optimisation
	iterate_over_nodes(scene)
	
	# Setup higher tilemaps
	remove_collision_from_higher_tilemaps(scene.find_node("higher"))
	
	print("POST_IMPORT_BUILDINGS: Reimported " + scene.name + "! \n")
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


# Method to iterate over all nodes in "higher" and sets specific properties
func remove_collision_from_higher_tilemaps(node):
	for child in node.get_children():
		if child.get_child_count() > 0:
			remove_collision_from_higher_tilemaps(child)
		else:
			if child is TileMap:
				# Disable collision from tilemap
				child.set_collision_layer_bit(0, false)
