extends Node2D

# Variables
var thread
var player_in_change_scene_area = false
var current_area : Area2D = null

# Variables - Data passed from scene before
var init_transition_data = null

# Nodes
onready var changeScenesObject = get_node("map_grassland/changeScenes")
onready var stairsObject = get_node("map_grassland/ground/stairs")
onready var navigation = $map_grassland/Navigation2D
onready var navigationTileMap = $map_grassland/Navigation2D/NavigationTileMap
onready var mobsLayer = $map_grassland/entitylayer/mobslayer
onready var batSpawnArea2D = $map_grassland/mobSpawns/batSpawning/
onready var batSpawnAreaPolygon = $map_grassland/mobSpawns/batSpawning/CollisionPolygon2D

# Mobs
var bat = preload("res://scenes/mobs/Bat.tscn")

# Mob Spawning Areas
var batSpawnArea

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup scene in background
	thread = Thread.new()
	thread.start(self, "_setup_scene_in_background")
	
	# Generate spawning areas
	batSpawnArea = Utils.generate_mob_spawn_area_from_polygon(batSpawnArea2D.position, batSpawnAreaPolygon.polygon)
	
	# Spawn mobs
	for i in range(1):
		var batInstance = bat.instance()
		batInstance.init(navigation, batSpawnArea)
		mobsLayer.add_child(batInstance)

# Method to setup this scene with a thread in background
func _setup_scene_in_background():
	# Setup player
	setup_player()
	
	# Setup areas to change areaScenes
	setup_change_scene_areas()
	
	# Setup stair areas
	setup_stair_areas()
	
	call_deferred("_on_setup_scene_done")
	
# Method is called when thread is done and the scene is setup
func _on_setup_scene_done():
	thread.wait_to_finish()
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()

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
func interaction_detected():
	if player_in_change_scene_area:
		var next_scene_path = current_area.get_meta("next_scene_path")
		print("-> Change scene \"DUNGEON\" to \""  + str(next_scene_path) + "\"")
		var transition_data = TransitionData.GameArea.new(next_scene_path, current_area.get_meta("to_spawn_area_id"), Vector2(0, 1))
		Utils.get_scene_manager().transition_to_scene(transition_data)

# Method which is called when a body has entered a changeSceneArea
func body_entered_change_scene_area(body, changeSceneArea):
	if body.name == "Player":
		if changeSceneArea.get_meta("need_to_press_button_for_change") == false:
			var next_scene_path = changeSceneArea.get_meta("next_scene_path")
			print("-> Change scene \"GRASSLAND\" to \""  + str(next_scene_path) + "\"")
			var transition_data = TransitionData.GameArea.new(next_scene_path, changeSceneArea.get_meta("to_spawn_area_id"), Vector2(0, 1))
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
		
# Method which is called when a body has entered a stairArea
func body_entered_stair_area(body, _stairArea):
	if body.name == "Player":
		# reduce player speed
		Utils.get_current_player().set_speed(Constants.PLAYER_STAIR_SPEED_FACTOR)

# Method which is called when a body has exited a stairArea
func body_exited_stair_area(body, _stairArea):
	if body.name == "Player":
		# reset player speed
		Utils.get_current_player().reset_speed()

# Setup all change_scene objectes/Area2D's on start
func setup_change_scene_areas():
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.connect("body_entered", self, "body_entered_change_scene_area", [child])
			child.connect("body_exited", self, "body_exited_change_scene_area", [child])

# Setup all stair objectes/Area2D's on start
func setup_stair_areas():
	for stair in stairsObject.get_children():
		if "stairs" in stair.name:
			# connect Area2D with functions to handle body action
			stair.connect("body_entered", self, "body_entered_stair_area", [stair])
			stair.connect("body_exited", self, "body_exited_stair_area", [stair])
