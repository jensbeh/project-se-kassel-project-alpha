extends Node

# Method to change the scene directly after it is imported by Tiled Map Importer
func post_import(scene):
	print("reimporte " + scene.name + "...")
	
	# Setup map - performace optimisation
	iterate_over_nodes(scene)
	
	# Setup all doors with animation
	var doorsObject = scene.find_node("doors")
	if doorsObject != null and doorsObject.get_children().size() > 0:
		for child in doorsObject.get_children():
			if "door_" in child.name:
				var selected_door_sprite = child.get_meta("selected_door_sprite") # possible slected doors = 1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,24,29
				var frame = selected_door_sprite * 4 - 4
				var sprite = Sprite.new()
				sprite.name = "sprite"
				sprite.centered = false
				sprite.texture = load("res://assets/tilesets/Village Animated Doors.png")
				sprite.hframes = 20
				sprite.vframes = 8
				sprite.frame = frame
				
				child.add_child(sprite)
				sprite.set_owner(scene)
				
				var animationPlayer = AnimationPlayer.new()
				animationPlayer.name = "animationPlayer"
				var path = sprite.name + ":frame"
				
				var idleDoorAnimation = Animation.new()
				animationPlayer.add_animation( "idleDoor", idleDoorAnimation)
				idleDoorAnimation.add_track(0)
				idleDoorAnimation.length = 0.4
				idleDoorAnimation.track_set_path(0, path)
				idleDoorAnimation.track_insert_key(0, 0.0, frame)
				idleDoorAnimation.value_track_set_update_mode(0, Animation.UPDATE_DISCRETE)
				idleDoorAnimation.loop = 0

				var openDoorAnimation = Animation.new()
				animationPlayer.add_animation( "openDoor", openDoorAnimation)
				openDoorAnimation.add_track(0)
				openDoorAnimation.length = 0.4
				openDoorAnimation.track_set_path(0, path)
				openDoorAnimation.track_insert_key(0, 0.0, frame)
				openDoorAnimation.track_insert_key(0, 0.1, frame + 1)
				openDoorAnimation.track_insert_key(0, 0.2, frame + 2)
				openDoorAnimation.track_insert_key(0, 0.3, frame + 3)
				openDoorAnimation.value_track_set_update_mode(0, Animation.UPDATE_DISCRETE)
				openDoorAnimation.loop = 0
				
				var closeDoorAnimation = Animation.new()
				animationPlayer.add_animation( "closeDoor", closeDoorAnimation)
				closeDoorAnimation.add_track(0)
				closeDoorAnimation.length = 0.4
				closeDoorAnimation.track_set_path(0, path)
				closeDoorAnimation.track_insert_key(0, 0.0, frame + 3)
				closeDoorAnimation.track_insert_key(0, 0.1, frame + 2)
				closeDoorAnimation.track_insert_key(0, 0.2, frame + 1)
				closeDoorAnimation.track_insert_key(0, 0.3, frame)
				closeDoorAnimation.value_track_set_update_mode(0, Animation.UPDATE_DISCRETE)
				closeDoorAnimation.loop = 0
				
				animationPlayer.current_animation = "idleDoor"
				animationPlayer.autoplay = "idleDoor"
				
				child.add_child(animationPlayer)
				animationPlayer.set_owner(scene)
				
	# Set lights with script to groundLightsObject
	var groundLightsObject = scene.find_node("ground_lights")
	if groundLightsObject != null and groundLightsObject.get_children().size() > 0:
		for child in groundLightsObject.get_children():
			if child is Sprite:
				var sprite_positon = child.position
				var custom_light = load("res://scenes/light/CustomLight.tscn").instance()
				custom_light.radius = 64
				custom_light.position = Vector2(sprite_positon.x + 8, sprite_positon.y - 8)
				
				groundLightsObject.add_child(custom_light)
				custom_light.set_owner(scene)
				
	# Set lights with script to higherLightsObject
	var higherLightsObject = scene.find_node("higher_lights")
	if higherLightsObject != null and higherLightsObject.get_children().size() > 0:
		for child in higherLightsObject.get_children():
			if child is Sprite:
				var sprite_positon = child.position
				var custom_light = load("res://scenes/light/CustomLight.tscn").instance()
				custom_light.radius = 64
				custom_light.position = Vector2(sprite_positon.x + 8, sprite_positon.y - 8)
				
				higherLightsObject.add_child(custom_light)
				custom_light.set_owner(scene)
			
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
