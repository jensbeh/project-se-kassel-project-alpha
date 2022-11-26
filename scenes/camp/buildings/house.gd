extends Node2D


# Map specific
var scene_type = Constants.SceneType.HOUSE

# Variables
var current_area : Area2D = null
var current_bed_area : Area2D = null

# Variables - Data passed from scene before
var init_transition_data = null

# Nodes
onready var changeScenesObject = find_node("changeScenes")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Music
	Utils.set_and_play_music(Constants.PreloadedMusic.House)
	
	# Setup player
	setup_player()
	
	# setup areas to change areaScenes
	setup_change_scene_areas()
	
	# setup bed areas
	setup_bed_areas()
	
	# Connect signals
	Utils.get_current_player().connect("player_interact", self, "interaction_detected")
	
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
	
	# Remove scene_player
	scene_player.get_parent().remove_child(scene_player)
	scene_player.queue_free()
	
	# Replace template player in scene with current_player
	find_node("playerlayer").add_child(Utils.get_current_player())


# Method to set transition_data which contains stuff about the player and the transition
func set_transition_data(transition_data):
	init_transition_data = transition_data


# Method to handle interaction of player
func interaction_detected():
	if current_bed_area != null:
		# Start skip time animation
		Utils.get_main().start_skip_time_transition()


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
			Utils.set_and_play_sound(Constants.PreloadedSounds.open_door)
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


# Setup all bed objectes/Area2D's on start
func setup_bed_areas():
	var beds_node = find_node("bed")
	if beds_node != null:
		for bed_area in beds_node.get_children():
			if "bed" in bed_area.name:
				# connect Area2D with functions to handle body action
				bed_area.connect("body_entered", self, "body_entered_bed_area", [bed_area])
				bed_area.connect("body_exited", self, "body_exited_bed_area", [bed_area])


# Method which is called when a body has entered a bedArea
func body_entered_bed_area(body, bedArea):
	if body.name == "Player":
		current_bed_area = bedArea


# Method which is called when a body has exited a bedArea
func body_exited_bed_area(body, bedArea):
	if body.name == "Player":
		print("HOUSE: Body \""  + str(body.name) + "\" EXITED bedArea \"" + bedArea.name + "\"")
		current_bed_area = null


# Method to disconnect all signals
func clear_signals():
	# Change scenes
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.disconnect("body_entered", self, "body_entered_change_scene_area")
			child.disconnect("body_exited", self, "body_exited_change_scene_area")
