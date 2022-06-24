extends Node2D

# Variables - Data passed from scene before
var init_transition_data = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup player
	setup_player()
	
	# Setup scene with properties
	setup_scene()
	
	# Setup areas to change areaScenes
	setup_change_scene_areas()
	
	# Setup stair areas
	setup_stair_areas()
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()

func setup_player():
	Utils.get_current_player().setup_player_in_new_scene(find_node("Player"))
	
	# Set position
	if init_transition_data.is_type(TransitionData.GameArea):
		var player_spawn_area = null
		for child in find_node("playerSpawns").get_children():
			if "player_spawn" in child.name:
				if child.has_meta("spawn_area_id"):
					if child.get_meta("spawn_area_id") == init_transition_data.get_spawn_area_id():
						player_spawn_area = child
						break

		var player_position = Vector2(player_spawn_area.position.x + 5, player_spawn_area.position.y)
		var view_direction = Vector2(0,-1)
		Utils.get_current_player().set_spawn(player_position, view_direction)
		
	# Replace template player in scene with current_player
	find_node("Player").get_parent().remove_child(find_node("Player"))
	Utils.get_current_player().get_parent().remove_child(Utils.get_current_player())
	find_node("playerlayer").add_child(Utils.get_current_player())
	
	# Connect signals
	Utils.get_current_player().connect("player_collided", self, "collision_detected")
	Utils.get_current_player().connect("player_interact", self, "interaction_detected")

func set_transition_data(transition_data):
	init_transition_data = transition_data

# Method which is called when a body has entered a changeSceneArea
func body_entered_change_scene_area(body, changeSceneArea):
	if body.name == "Player":
		var change_scene_to = changeSceneArea.get_meta("change_scene_to")
		if change_scene_to == "camp":
			print("-> Change scene \"GRASSLAND\" to \""  + str(change_scene_to) + "\"")
			
			var transition_data = TransitionData.GameArea.new("res://scenes/camp/Camp.tscn", changeSceneArea.get_meta("to_spawn_area_id"))
			Utils.get_scene_manager().transition_to_scene(transition_data)


# Method which is called when a body has exited a changeSceneArea
func body_exited_change_scene_area(body, changeSceneArea):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" EXITED changeSceneArea \"" + changeSceneArea.name + "\"")

# Method which is called when a body has entered a stairArea
func body_entered_stair_area(body, stairArea):
	if body.name == "Player":
		# reduce player speed
		Utils.get_current_player().set_speed(0.6)

# Method which is called when a body has exited a stairArea
func body_exited_stair_area(body, stairArea):
	if body.name == "Player":
		# reset player speed
		Utils.get_current_player().reset_speed()

# Setup the scene with all importent properties on start
func setup_scene():
	find_node("dirt lvl0").cell_quadrant_size = 1
	find_node("dirt lvl0").cell_y_sort = false
	find_node("ground lvl0").cell_quadrant_size = 1
	find_node("ground lvl0").cell_y_sort = false
	find_node("decoration lvl0").cell_quadrant_size = 1
	find_node("decoration lvl0").cell_y_sort = false
	
	find_node("dirt lvl1").cell_quadrant_size = 1
	find_node("dirt lvl1").cell_y_sort = false
	find_node("ground lvl1").cell_quadrant_size = 1
	find_node("ground lvl1").cell_y_sort = false
	
	find_node("dirt lvl2").cell_quadrant_size = 1
	find_node("dirt lvl2").cell_y_sort = false
	find_node("ground lvl2").cell_quadrant_size = 1
	find_node("ground lvl2").cell_y_sort = false
	
	find_node("dirt lvl3").cell_quadrant_size = 1
	find_node("dirt lvl3").cell_y_sort = false
	find_node("ground lvl3").cell_quadrant_size = 1
	find_node("ground lvl3").cell_y_sort = false
	find_node("bridge lvl3").cell_quadrant_size = 1
	find_node("bridge lvl3").cell_y_sort = false
	
	find_node("dirt lvl4").cell_quadrant_size = 1
	find_node("dirt lvl4").cell_y_sort = false
	find_node("ground lvl4").cell_quadrant_size = 1
	find_node("ground lvl4").cell_y_sort = false


# Setup all change_scene objectes/Area2D's on start
func setup_change_scene_areas():
	var changeScenesObject = get_node("map_grassland/changeScenes")
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.connect("body_entered", self, "body_entered_change_scene_area", [child])
			child.connect("body_exited", self, "body_exited_change_scene_area", [child])

# Setup all stair objectes/Area2D's on start
func setup_stair_areas():
	var stairsObject = get_node("map_grassland/ground/stairs")
	for stair in stairsObject.get_children():
		if "stairs" in stair.name:
			# connect Area2D with functions to handle body action
			stair.connect("body_entered", self, "body_entered_stair_area", [stair])
			stair.connect("body_exited", self, "body_exited_stair_area", [stair])
