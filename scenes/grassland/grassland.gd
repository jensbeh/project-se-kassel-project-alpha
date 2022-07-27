extends Node2D

# Map specific
var current_ambient_mobs = 0
var max_ambient_mobs = 50

# Variables
var thread
var player_in_change_scene_area = false
var current_area : Area2D = null
var mob_list : Array
var mobs_to_remove : Array
var check_spawn_despawn_timer = 0.0
var max_check_spawn_despawn_time = 15.0
var spawning_areas = {}

# Variables - Data passed from scene before
var init_transition_data = null

# Nodes
onready var changeScenesObject = $map_grassland/changeScenes
onready var stairsObject = $map_grassland/ground/stairs
onready var mobsNavigation2d = $map_grassland/mobs_navigation2d
onready var mobsNavigationTileMap = $map_grassland/mobs_navigation2d/NavigationTileMap
onready var ambientMobsNavigation2d = $map_grassland/ambient_mobs_navigation2d
onready var ambientMobsNavigationPolygonInstance = $map_grassland/ambient_mobs_navigation2d/NavigationPolygonInstance
onready var mobsLayer = $map_grassland/entitylayer/mobslayer
onready var mobSpawns = $map_grassland/mobSpawns
onready var ambientMobsLayer = $map_grassland/ambientMobsLayer

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
	
	# Setup stair areas
	setup_stair_areas()
	
	
	# Setup pathfinding
	PathfindingService.init(mobsNavigation2d, ambientMobsNavigation2d)
	
	# Setup spawning areas
	setup_spawning_areas()
	
	# Spawn all mobs
	spawn_mobs()
	
	# Connect signals
	DayNightCycle.connect("change_to_sunrise", self, "on_change_to_sunrise")
	DayNightCycle.connect("change_to_night", self, "on_change_to_night")
	
	
	call_deferred("_on_setup_scene_done")
	
# Method is called when thread is done and the scene is setup
func _on_setup_scene_done():
	thread.wait_to_finish()
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()


# Method to set transition_data which contains stuff about the player and the transition
func set_transition_data(transition_data):
	init_transition_data = transition_data


func _physics_process(delta):
	check_spawn_despawn_timer += delta
	if check_spawn_despawn_timer >= max_check_spawn_despawn_time:
		check_spawn_despawn_timer = 0.0
		print("-------------------------> REMOVE MOBS")
		remove_mobs(mobs_to_remove)
		spawn_mobs()


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
		
		print(spawning_areas)

func spawn_mobs():
	# Spawn area mobs
	spawn_area_mobs()
	
	# Spawn ambient mobs
	spawn_ambient_mobs()


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

func on_change_to_sunrise():
	# Spawn specific day mobs and remove specific night mobs
	print("day")
	# Remove mobs
	var remove_mobs : Array
	for mob in mob_list:
		if mob.spawn_time == Constants.SpawnTime.ONLY_NIGHT:
			remove_mobs.append(mob)
	remove_mobs(remove_mobs)
	
	# Spawn mobs
	spawn_mobs()


func on_change_to_night():
	# Spawn specific night mobs and remove specific day mobs
	print("night")
	# Remove mobs
	var remove_mobs : Array
	for mob in mob_list:
		if mob.spawn_time == Constants.SpawnTime.ONLY_DAY:
			remove_mobs.append(mob)
	remove_mobs(remove_mobs)
	
	# Spawn mobs
	spawn_mobs()


func remove_mobs(mobs : Array):
	for mob in mobs:
		# Remove mob if it is not in camera screen
		if not Utils.is_position_in_camera_screen(mob.global_position):
			if mob.is_in_group("Ambient Mob"):
				current_ambient_mobs -= 1
				print("removed ambient mob: " + str(current_ambient_mobs))
			elif mob.is_in_group("Enemy"):
				spawning_areas[mob.spawnArea]["current_mobs_count"] -= 1
				print("removed enemy mob: " + str(spawning_areas[mob.spawnArea]["current_mobs_count"]))
			mob.get_parent().remove_child(mob)
			mob.queue_free()
			mob_list.remove(mob_list.find(mob))
			if mob in mobs_to_remove:
				mobs_to_remove.remove(mobs_to_remove.find(mob))
			
			
		else:
			# Add mob to list where is will be removed when its not visible in screen anymore
			if not mob in mobs_to_remove:
				mobs_to_remove.append(mob)


func spawn_ambient_mobs():
	# Spawn ambient mobs
	var polygon = Polygon2D.new()
	polygon.polygon = ambientMobsNavigationPolygonInstance.navpoly.get_vertices()
	var ambientMobsSpawnArea = Utils.generate_mob_spawn_area_from_polygon(polygon.position, polygon.polygon)
	
	# Check time
	if DayNightCycle.is_night:
		# NIGHT
		# Spawn moths
		var mobScene : Resource = load("res://scenes/mobs/Moth.tscn")
		if mobScene != null:
			while current_ambient_mobs < max_ambient_mobs:
				var mob_instance = mobScene.instance()
				mob_instance.init(ambientMobsSpawnArea, Constants.SpawnTime.ONLY_NIGHT)
				ambientMobsLayer.add_child(mob_instance)
				mob_list.append(mob_instance)
				current_ambient_mobs += 1
		else:
			printerr("\"Moth\" scene can't be loaded!")

	else:
		# DAY
		# Spawn butterflies
		var mobScene : Resource = load("res://scenes/mobs/Butterfly.tscn")
		if mobScene != null:
			while current_ambient_mobs < max_ambient_mobs:
				var mob_instance = mobScene.instance()
				mob_instance.init(ambientMobsSpawnArea, Constants.SpawnTime.ONLY_DAY)
				ambientMobsLayer.add_child(mob_instance)
				mob_list.append(mob_instance)
				current_ambient_mobs += 1
		else:
			printerr("\"Butterfly\" scene can't be loaded!")


func spawn_area_mobs():
# e.g. spawning_areas[spawnArea] = {
#								"biome": "forest",
#								"max_mobs": 15,
#								"current_mobs_count": 0,
#								"biome_mobs": [Bat],
#								"biome_mobs_count": 1
#								}
	
	for current_area in spawning_areas.keys():
		var biome_mobs_count = spawning_areas[current_area]["biome_mobs_count"]
		var max_mobs = spawning_areas[current_area]["max_mobs"]
		var biome_mobs = spawning_areas[current_area]["biome_mobs"]
		spawning_areas[current_area]["current_mobs_count"]
		
		var spawn_mobs_counter = max_mobs - spawning_areas[current_area]["current_mobs_count"]
		
		var mob_count_breakdown : Array = Utils.n_random_numbers_with_max_sum(biome_mobs_count, spawn_mobs_counter)
		print("mob_count_breakdown: " + str(mob_count_breakdown))
		# Iterate over diffent mobs classes
		for i_mob in range(biome_mobs.size()):
			# Load and spawn mobs
			var mobScene : Resource = load("res://scenes/mobs/" + biome_mobs[i_mob] + ".tscn")
			if mobScene != null:
				for _num in range(mob_count_breakdown[i_mob]):
					var mob_instance = mobScene.instance()
					mob_instance.init(current_area, mobsNavigationTileMap)
					mobsLayer.add_child(mob_instance)
					mob_list.append(mob_instance)
					spawning_areas[current_area]["current_mobs_count"] += 1
					print(spawning_areas[current_area]["current_mobs_count"])
			else:
				printerr("\""+ biome_mobs[i_mob] + "\" scene can't be loaded!")
