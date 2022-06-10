extends Node2D

#onready var door = $"camp/Level 1/Buildings/House 3/door/75/CollisionShape2D"

# Called when the node enters the scene tree for the first time.
func _ready():
	# setup all door animations
	setup_door_animations()
	# setup all market buyingZone collisions
	setup_market_buying_zone_collisions()
	
	# ONLY FOR TESTING
	setup_test()
	
	var player = Utils.get_player()
	player.connect("player_collided", self, "collision_detected")

# Method to handle collision detetcion dependent of the collision object type
func collision_detected(collision):
	var type = collision.get_parent().get_meta("type") # type is string
	
	if type == "Door":
		var doorSpriteName = collision.get_meta("door_name")		
		var houseId = collision.get_meta("enter_house")
		print("-> Enter House: \"" + houseId + "\"")
		start_door_animation(find_node(doorSpriteName))
		
	elif type == "BuyingZone":
		var marketId = collision.get_meta("enter_market")
		print("-> Enter Market: \"" + marketId + "\"")

func start_door_animation(door):
	if door.get_texture().pause == true:
		door.get_texture().pause = false
		
func body_entered_buying_zone(body, area):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" ENTERED buying zone \"" + area.name + "\"")
		
func body_exited_buying_zone(body, area):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" EXITED buying zone \"" + area.name + "\"")
		
		
func body_entered_door(body, area):
	for child in area.get_children():
		if "animationPlayer" in child.name:
			child.play("openDoor")
			
func body_exited_door(body, area):
	for child in area.get_children():
		if "animationPlayer" in child.name:
			child.play("closeDoor")

# ONLY FOR TESTING
func setup_test():
	var testObject = get_node("camp/Level 1/ground/Buildings/test")
	for child in testObject.get_children():
		if "test_door" in child.name:
			# add animation to pos
			child.connect("body_entered", self, "body_entered_door", [child])
			child.connect("body_exited", self, "body_exited_door", [child])
			
# Setup and stop all door animations on start
func setup_door_animations():
	var doorsObject = get_node("camp/Level 1/ground/Buildings/doors")
	for child in doorsObject.get_children():
		if "door" in child.name:
			var animatedDoor = child
			animatedDoor.get_texture().pause = true
			animatedDoor.get_texture().current_frame = 0
			animatedDoor.get_texture().oneshot = true
			
# Setup all market buyingZones to walk on
func setup_market_buying_zone_collisions():
	var buyingZoneObject = get_node("camp/Level 1/ground/Buildings/buyingZones")
	for buyingZoneArea2D in buyingZoneObject.get_children():
		buyingZoneArea2D.connect("body_entered", self, "body_entered_buying_zone", [buyingZoneArea2D])
		buyingZoneArea2D.connect("body_exited", self, "body_exited_buying_zone", [buyingZoneArea2D])
