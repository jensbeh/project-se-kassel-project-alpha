extends Node

# Variables
var thread
var next_level_to  = null
var current_dungeon  = null
var player_in_change_scene_area = false
var current_area : Area2D = null
var spawning_areas = {}
var mob_list : Array

# Variables - Data passed from scene before
var init_transition_data = null

# Nodes
onready var mobsNavigation2d = find_node("mobs_navigation2d")
onready var mobsNavigationTileMap = find_node("NavigationTileMap")
onready var mobSpawns = find_node("mobSpawns")
onready var mobsLayer = find_node("mobslayer")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup scene in background
	thread = Thread.new()
	thread.start(self, "_setup_scene_in_background")
	
# Method to setup this scene with a thread in background
func _setup_scene_in_background():
	# Setup player
	setup_player()
	
	# Setup areas to change areaScenes
	setup_change_scene_areas()
	print("INIT")
	# Setup pathfinding
	PathfindingService.init(mobsNavigation2d)
	print("INIT2")
	# Setup spawning areas
	setup_spawning_areas()
	print("INIT3")
	# Spawn all mobs
	spawn_mobs()
	print("INIT4")
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
			print("-> Change scene \"DUNGEON\" to \""  + str(next_scene_path) + "\"")
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

# Setup all change_scene objectes/Area2D's on start
func setup_change_scene_areas():
	var changeScenesObject = find_node("changeScenes")
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.connect("body_entered", self, "body_entered_change_scene_area", [child])
			child.connect("body_exited", self, "body_exited_change_scene_area", [child])


func setup_spawning_areas():
	for area in mobSpawns.get_children():
		var biome : String = area.get_meta("biome")
		var max_mobs = area.get_meta("max_mobs")
		
		# Get biome data from json
		var file = File.new()
		file.open("res://assets/biomes/"+ biome + ".json", File.READ)
		var biome_json = parse_json(file.get_as_text())
		var biome_mobs : Array = biome_json["data"]["mobs"]
		var biome_mobs_count = biome_mobs.size()
		var current_mobs_count = 0
		# Generate spawning areas
		var spawnArea = Utils.generate_mob_spawn_area_from_polygon(area.position, area.get_child(0).polygon)
		
		# Save spawning area
		spawning_areas[spawnArea] = {"biome": biome, "max_mobs": max_mobs, "current_mobs_count": current_mobs_count, "biome_mobs": biome_mobs, "biome_mobs_count": biome_mobs_count}
		
#	print(spawning_areas)


func spawn_mobs():
# e.g. spawning_areas[spawnArea] = {
#								"biome": "forest",
#								"max_mobs": 15,
#								"current_mobs_count": 0,
#								"biome_mobs": [Bat],
#								"biome_mobs_count": 1
#								}
	
	for current_spawn_area in spawning_areas.keys():
		var biome_mobs_count = spawning_areas[current_spawn_area]["biome_mobs_count"]
		var max_mobs = spawning_areas[current_spawn_area]["max_mobs"]
		var biome_mobs = spawning_areas[current_spawn_area]["biome_mobs"]
		
		var spawn_mobs_counter = max_mobs - spawning_areas[current_spawn_area]["current_mobs_count"]
		
		var mob_count_breakdown : Array = Utils.n_random_numbers_with_max_sum(biome_mobs_count, spawn_mobs_counter)
#		print("mob_count_breakdown: " + str(mob_count_breakdown))
		# Iterate over diffent mobs classes
		for i_mob in range(biome_mobs.size()):
			# Load and spawn mobs
			var mobScene : Resource = load("res://scenes/mobs/" + biome_mobs[i_mob] + ".tscn")
			if mobScene != null:
				for _num in range(mob_count_breakdown[i_mob]):
					var mob_instance = mobScene.instance()
#					print(current_spawn_area)
#					print(mobsNavigationTileMap)
					mob_instance.init(current_spawn_area, mobsNavigationTileMap)
					mobsLayer.call_deferred("add_child", mob_instance)
					mob_list.append(mob_instance)
					spawning_areas[current_spawn_area]["current_mobs_count"] += 1
#					print(spawning_areas[current_spawn_area]["current_mobs_count"])
			else:
				printerr("\""+ biome_mobs[i_mob] + "\" scene can't be loaded!")
