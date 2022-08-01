extends Node2D

# Variables
var thread
var player_in_change_scene_area = false
var current_area : Area2D = null

# Variables - Data passed from scene before
var init_transition_data = null

# Nodes
onready var changeScenesObject = get_node("map_camp/changeScenes")
onready var doorsObject = get_node("map_camp/ground/Buildings/doors")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup scene in background
	thread = Thread.new()
	thread.start(self, "_setup_scene_in_background")

# Method to setup this scene with a thread in background
func _setup_scene_in_background():
	# Setup player
	setup_player()

	# setup areas to change areaScenes
	setup_change_scene_areas()
	# setup all door areas to handle action
	setup_door_areas()
	
	call_deferred("_on_setup_scene_done")

# Method is called when thread is done and the scene is setup
func _on_setup_scene_done():
	thread.wait_to_finish()
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()


# Method to destroy the scene
# Is called when SceneManager changes scene after loading new scene
func destroy_scene():
	pass


# Method to setup the player with all informations
func setup_player():
	var scene_player = find_node("Player")
	
	# Setup player node with all settings like camera, ...
	Utils.get_current_player().setup_player_in_new_scene(scene_player)
	
	# Set position
	Utils.calculate_and_set_player_spawn(self, init_transition_data)
	
	# Replace template player in scene with current_player
	scene_player.get_parent().remove_child(scene_player)
	Utils.get_current_player().get_parent().remove_child(Utils.get_current_player())
	find_node("playerlayer").add_child(Utils.get_current_player())
	
	# Connect signals
	Utils.get_current_player().connect("player_collided", self, "collision_detected")
	Utils.get_current_player().connect("player_interact", self, "interaction_detected")

# Method to set transition_data which contains stuff about the player and the transition
func set_transition_data(transition_data):
	init_transition_data = transition_data

# Method to handle collision detetcion dependent of the collision object type
func collision_detected(collision):
	var _type = collision.get_parent().get_meta("type") # type is string
	print("collision_detected")
	
# Method to handle collision detetcion dependent of the collision object type
func interaction_detected():
	if player_in_change_scene_area:
		var next_scene_path = current_area.get_meta("next_scene_path")
		print("-> Change scene \"DUNGEON\" to \""  + str(next_scene_path) + "\"")
		var transition_data = TransitionData.GameArea.new(next_scene_path, current_area.get_meta("to_spawn_area_id"), Vector2(0, 1))
		Utils.get_scene_manager().transition_to_scene(transition_data)
		
		
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
		if changeSceneArea.get_meta("need_to_press_button_for_change") == false:
			var next_scene_path = changeSceneArea.get_meta("next_scene_path")
			print("-> Change scene \"CAMP\" to \""  + str(next_scene_path) + "\"")
			var transition_data = TransitionData.GameArea.new(next_scene_path, changeSceneArea.get_meta("to_spawn_area_id"), Vector2(0, -1))
			Utils.get_scene_manager().transition_to_scene(transition_data)
		else:
			player_in_change_scene_area = true
			current_area = changeSceneArea
	
# Method which is called when a body has exited a changeSceneArea
func body_exited_change_scene_area(body, changeSceneArea):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" EXITED changeSceneArea \"" + changeSceneArea.name + "\"")
		current_area = null
		player_in_change_scene_area = false

# Setup all change_scene objectes/Area2D's on start
func setup_change_scene_areas():
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.connect("body_entered", self, "body_entered_change_scene_area", [child])
			child.connect("body_exited", self, "body_exited_change_scene_area", [child])

# Setup all door objectes/Area2D's on start
func setup_door_areas():
	for door in doorsObject.get_children():
		if "door_" in door.name:
			# connect Area2D with functions to handle body action
			door.connect("body_entered", self, "body_entered_door", [door])
			door.connect("body_exited", self, "body_exited_door", [door])
