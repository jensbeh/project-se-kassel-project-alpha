extends Node

# Method to change the scene directly after it is imported by Tiled Map Importer
func post_import(scene):
	print("reimported " + scene.name)
	
	# Setup map - performace optimisation
	iterate_over_nodes(scene)
	
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
