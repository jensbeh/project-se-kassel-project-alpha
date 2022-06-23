extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup scene with properties
	setup_scene()
	
	# setup areas to change areaScenes
	setup_change_scene_areas()
	# setup all door areas to handle action
	setup_door_areas()
	# setup all market buyingZone areas to handle action
	setup_market_buying_zone_areas()
	
	var player = Utils.get_player()
	player.connect("player_collided", self, "collision_detected")

# Method to handle collision detetcion dependent of the collision object type
func collision_detected(collision):
	var type = collision.get_parent().get_meta("type") # type is string
	print("collision_detected")

# Method which is called when a body has entered a buyingZoneArea
func body_entered_buying_zone(body, buyingZoneArea):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" ENTERED buying zone \"" + buyingZoneArea.name + "\"")

# Method which is called when a body has exited a buyingZoneArea
func body_exited_buying_zone(body, buyingZoneArea):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" EXITED buying zone \"" + buyingZoneArea.name + "\"")
		
# Method which is called when a body has entered a doorArea
func body_entered_door(body, doorArea):
	if body.name == "Player":
		for child in doorArea.get_children():
			if "animationPlayer" in child.name:
				# Start door animation
				child.play("openDoor")

# Method which is called when a body has exited a doorArea
func body_exited_door(body, doorArea):
	if body.name == "Player":
		for child in doorArea.get_children():
			if "animationPlayer" in child.name:
				# Start door animation
				child.play("closeDoor")

# Method which is called when a body has entered a changeSceneArea
func body_entered_change_scene_area(body, changeSceneArea):
	if body.name == "Player":
		var change_scene_to = changeSceneArea.get_meta("change_scene_to")
		if change_scene_to == "grassland":
			print("-> Change scene \"CAMP\" to \""  + str(change_scene_to) + "\"")

# Method which is called when a body has exited a changeSceneArea
func body_exited_change_scene_area(body, changeSceneArea):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" EXITED changeSceneArea \"" + changeSceneArea.name + "\"")

# Setup the scene with all importent properties on start
func setup_scene():
	get_node("camp/Level 1/ground/dirt").cell_quadrant_size = 1
	get_node("camp/Level 1/ground/dirt").cell_y_sort = false
	
	get_node("camp/Level 1/ground/ground").cell_quadrant_size = 1
	get_node("camp/Level 1/ground/ground").cell_y_sort = false	
	
	get_node("camp/Level 1/ground/little stones in water").cell_quadrant_size = 1
	get_node("camp/Level 1/ground/little stones in water").cell_y_sort = false
	
	get_node("camp/Level 1/ground/bridge").cell_quadrant_size = 1
	get_node("camp/Level 1/ground/bridge").cell_y_sort = false
	
	get_node("camp/Level 1/ground/fences").cell_quadrant_size = 1
	get_node("camp/Level 1/ground/fences").cell_y_sort = false
	
	get_node("camp/Level 1/ground/decorations layer1").cell_quadrant_size = 1
	get_node("camp/Level 1/ground/decorations layer1").cell_y_sort = false
	
	get_node("camp/Level 1/ground/decorations layer2").cell_quadrant_size = 1
	get_node("camp/Level 1/ground/decorations layer2").cell_y_sort = false
	

# Setup all change_scene objectes/Area2D's on start
func setup_change_scene_areas():
	var changeScenesObject = get_node("camp/Level 1/changeScenes")
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.connect("body_entered", self, "body_entered_change_scene_area", [child])
			child.connect("body_exited", self, "body_exited_change_scene_area", [child])

# Setup all door objectes/Area2D's on start
func setup_door_areas():
	var doorsObject = get_node("camp/Level 1/ground/Buildings/doors")
	for door in doorsObject.get_children():
		if "door_" in door.name:
			# connect Area2D with functions to handle body action
			door.connect("body_entered", self, "body_entered_door", [door])
			door.connect("body_exited", self, "body_exited_door", [door])

# Setup all buyingZone objectes/Area2D's on start
func setup_market_buying_zone_areas():
	var buyingZoneObject = get_node("camp/Level 1/ground/Buildings/buyingZones")
	for buyingZoneArea2D in buyingZoneObject.get_children():
		# connect Area2D with functions to handle body action
		buyingZoneArea2D.connect("body_entered", self, "body_entered_buying_zone", [buyingZoneArea2D])
		buyingZoneArea2D.connect("body_exited", self, "body_exited_buying_zone", [buyingZoneArea2D])
