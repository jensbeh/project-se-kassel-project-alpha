extends Node2D


# Map specific
var scene_type = Constants.SceneType.HOUSE

# Variables
var current_area : Area2D = null

# Variables - Data passed from scene before
var init_transition_data = null

# Nodes
onready var changeScenesObject = find_node("changeScenes")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup player
	setup_player()
	
	# setup areas to change areaScenes
	setup_change_scene_areas()
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()


# Method to destroy the scene
# Is called when SceneManager changes scene after loading new scene
func destroy_scene():
	# Disconnect signals
	clear_signals()


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
	Utils.get_current_player().connect("player_interact", self, "interaction_detected")


# Method to set transition_data which contains stuff about the player and the transition
func set_transition_data(transition_data):
	init_transition_data = transition_data


# Method to handle collision detetcion dependent of the collision object type
func interaction_detected():
	if Utils.get_current_player().is_in_change_scene_area():
		var next_scene_path = current_area.get_meta("next_scene_path")
		print("HOUSE: Change scene to \""  + str(next_scene_path) + "\"")
		var next_view_direction = Vector2(current_area.get_meta("view_direction_x"), current_area.get_meta("view_direction_y"))
		var transition_data = TransitionData.GameArea.new(next_scene_path, current_area.get_meta("to_spawn_area_id"), next_view_direction)
		Utils.get_scene_manager().transition_to_scene(transition_data)


# Setup all change_scene objectes/Area2D's on start
func setup_change_scene_areas():
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.connect("body_entered", self, "body_entered_change_scene_area", [child])
			child.connect("body_exited", self, "body_exited_change_scene_area", [child])


# Method which is called when a body has entered a changeSceneArea
func body_entered_change_scene_area(body, changeSceneArea):
	if body.name == "Player":
		if changeSceneArea.get_meta("need_to_press_button_for_change") == false:
			var next_scene_path = changeSceneArea.get_meta("next_scene_path")
			print("HOUSE: Change scene to \""  + str(next_scene_path) + "\"")
			var next_view_direction = Vector2(changeSceneArea.get_meta("view_direction_x"), changeSceneArea.get_meta("view_direction_y"))
			var transition_data = TransitionData.GameArea.new(next_scene_path, changeSceneArea.get_meta("to_spawn_area_id"), next_view_direction)
			Utils.get_scene_manager().transition_to_scene(transition_data)
		else:
			Utils.get_current_player().set_in_change_scene_area(true)
			current_area = changeSceneArea


# Method which is called when a body has exited a changeSceneArea
func body_exited_change_scene_area(body, changeSceneArea):
	if body.name == "Player":
		print("HOUSE: Body \""  + str(body.name) + "\" EXITED changeSceneArea \"" + changeSceneArea.name + "\"")
		current_area = null
		Utils.get_current_player().set_in_change_scene_area(false)


# Method to disconnect all signals
func clear_signals():
	# Player
	Utils.get_current_player().disconnect("player_interact", self, "interaction_detected")
	
	# Change scenes
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.disconnect("body_entered", self, "body_entered_change_scene_area")
			child.disconnect("body_exited", self, "body_exited_change_scene_area")
