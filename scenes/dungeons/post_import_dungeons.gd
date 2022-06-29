extends Node

# Method to change the scene directly after it is imported by Tiled Map Importer
func post_import(scene):
	print("reimported " + scene.name)
	
	# Setup map - performace optimisation
	iterate_over_nodes(scene)
	
	# Set lights with script to lightsObject
	var lightsObject = scene.find_node("lights")
	if lightsObject != null and lightsObject.get_children().size() > 0:
		for child in lightsObject.get_children():
			if child is Sprite:
				var sprite_positon = child.position
				var light = Light2D.new()
				light.texture = load("res://assets/light.png")
				light.position = Vector2(sprite_positon.x + 8, sprite_positon.y - 8)
				light.texture_scale = 0.2
				light.energy = 0.8
				light.color = Color("64ffde7e")
				
				light.set_script(load("res://scenes/dungeons/animated_lights.gd"))
				
				lightsObject.add_child(light)
				light.set_owner(scene)
				
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
