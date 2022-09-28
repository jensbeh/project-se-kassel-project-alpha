extends Node2D


# Map specific
var max_ambient_mobs = 50

# Variables
var thread
var player_in_change_scene_area = false
var current_area : Area2D = null
var spawning_areas = {}
var ambientMobsSpawnArea

# Variables - Data passed from scene before
var init_transition_data = null

# Nodes
onready var changeScenesObject = $map_grassland/changeScenes
onready var groundChunks = $map_grassland/ground/Chunks
onready var higherChunks = $map_grassland/higher/Chunks
onready var mobsNavigationTileMap = $map_grassland/mobs_navigation/mobs_navigation_tilemap
onready var ambientMobsNavigationTileMap = $map_grassland/ambient_mobs_navigation/ambient_mobs_navigation_tilemap
onready var ambientMobsNavigationPolygon = $map_grassland/ambient_mobs_navigation/Area2D/CollisionPolygon2D
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
	
	# Setup chunks and chunkloader
	# Get map position
	var vertical_chunks_count = groundChunks.get_meta("vertical_chunks_count") - 1
	var horizontal_chunks_count = groundChunks.get_meta("horizontal_chunks_count") - 1
	var map_min_global_pos = groundChunks.get_meta("map_min_global_pos")
	var map_size_in_tiles = groundChunks.get_meta("map_size_in_tiles")
	ChunkLoaderService.init(self, vertical_chunks_count, horizontal_chunks_count, map_min_global_pos)
	
	# Setup areas to change areaScenes
	setup_change_scene_areas()
	
	# Setup stair areas
	setup_stair_areas()
	
	# Setup pathfinding
	PathfindingService.init(mobsNavigationTileMap, ambientMobsNavigationTileMap, map_size_in_tiles)
	
	# Setup spawning areas
	setup_spawning_areas()
	
	# Spawn mobs
	MobSpawnerService.init(spawning_areas, mobsNavigationTileMap, mobsLayer, true, ambientMobsSpawnArea, ambientMobsNavigationTileMap, ambientMobsLayer, max_ambient_mobs, true)
	
	call_deferred("_on_setup_scene_done")


# Method is called when thread is done and the scene is setup
func _on_setup_scene_done():
	thread.wait_to_finish()
	
	# Spawn all mobs
	MobSpawnerService.spawn_mobs()
	
	# Spawn bosses
	spawn_bosses()
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()


# Method to spawn bosses in grassland
func spawn_bosses():
	for current_spawn_area in spawning_areas.keys():
		# Spawn area informations
		var biome_name = spawning_areas[current_spawn_area]["biome"]
		# Generate 2 bosses in mountain
		if biome_name == "mountain":
			for _i in range(2):
				# Take random boss
				var boss_path = Constants.BossPathes[randi() % Constants.BossPathes.size()]
				var boss_instance = load(boss_path).instance()
				# Generate spawn position and spawn boss
				boss_instance.init(current_spawn_area, mobsNavigationTileMap)
				boss_instance.is_boss_in_grassland(true)
				mobsLayer.call_deferred("add_child", boss_instance)
				print("SPAWNED BOSS \""+ str(boss_path) +"\" in " + str(biome_name))
		
		# Generate bosses with little chance in other biomes
		else:
			var random_float = randf()
			if random_float <= 0.1:
				# Take random boss
				var boss_path = Constants.BossPathes[randi() % Constants.BossPathes.size()]
				var boss_instance = load(boss_path).instance()
				# Generate spawn position and spawn boss
				boss_instance.init(current_spawn_area, mobsNavigationTileMap)
				boss_instance.is_boss_in_grassland(true)
				mobsLayer.call_deferred("add_child", boss_instance)
				print("SPAWNED BOSS \""+ str(boss_path) +"\" with 10% chance in " + str(biome_name))


# Method to destroy the scene
# Is called when SceneManager changes scene after loading new scene
func destroy_scene():
	# Stop pathfinder
	PathfindingService.stop()
	
	# Stop chunkloader
	ChunkLoaderService.stop()
	
	# Stop mobspawner
	MobSpawnerService.stop()


# Method to set transition_data which contains stuff about the player and the transition
func set_transition_data(transition_data):
	init_transition_data = transition_data


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


# Method to create spawning areas
func setup_spawning_areas():
	# AreaMobs spawning area
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
	
	
	# AmbientMobs spawning area
	ambientMobsSpawnArea = Utils.generate_mob_spawn_area_from_polygon(ambientMobsNavigationPolygon.position, ambientMobsNavigationPolygon.polygon)


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
			clear_signals()
			
			var next_scene_path = changeSceneArea.get_meta("next_scene_path")
			print("-> Change scene \"GRASSLAND\" to \""  + str(next_scene_path) + "\"")
			var transition_data = TransitionData.GameArea.new(next_scene_path, changeSceneArea.get_meta("to_spawn_area_id"), Vector2(0, 1))
			Utils.get_scene_manager().transition_to_scene(transition_data)
		else:
			player_in_change_scene_area = true
			current_area = changeSceneArea


# Method to disconnect all signals
func clear_signals():
	# Player
	Utils.get_current_player().disconnect("player_collided", self, "collision_detected")
	Utils.get_current_player().disconnect("player_interact", self, "interaction_detected")
	
	# Change scene areas
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.disconnect("body_entered", self, "body_entered_change_scene_area")
			child.disconnect("body_exited", self, "body_exited_change_scene_area")
	
	# Stairs
	for chunk in groundChunks.get_children():
		if chunk.has_node("stairs"):
			for stair in chunk.get_node("stairs").get_children():
				if "stairs" in stair.name:
					# connect Area2D with functions to handle body action
					stair.disconnect("body_entered", self, "body_entered_stair_area")
					stair.disconnect("body_exited", self, "body_exited_stair_area")


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
	for chunk in groundChunks.get_children():
		if chunk.has_node("stairs"):
			for stair in chunk.get_node("stairs").get_children():
				if "stairs" in stair.name:
					# connect Area2D with functions to handle body action
					stair.connect("body_entered", self, "body_entered_stair_area", [stair])
					stair.connect("body_exited", self, "body_exited_stair_area", [stair])


# Method to update the chunks with active and deleted chunks to make them visible or not
func update_chunks(new_chunks : Array, deleting_chunks : Array):
	# Activate chunks
	for chunk in new_chunks:
		var ground_chunk = groundChunks.get_node("Chunk (" + str(chunk.x) + "," + str(chunk.y) + ")")
		if ground_chunk != null and ground_chunk.is_inside_tree():
			ground_chunk.visible = true
		var higher_chunk = higherChunks.get_node("Chunk (" + str(chunk.x) + "," + str(chunk.y) + ")")
		if higher_chunk != null and higher_chunk.is_inside_tree():
			higher_chunk.visible = true
	
	# Disable chunks
	for chunk in deleting_chunks:
		var ground_chunk = groundChunks.get_node("Chunk (" + str(chunk.x) + "," + str(chunk.y) + ")")
		if ground_chunk != null and ground_chunk.is_inside_tree():
			ground_chunk.visible = false
		var higher_chunk = higherChunks.get_node("Chunk (" + str(chunk.x) + "," + str(chunk.y) + ")")
		if higher_chunk != null and higher_chunk.is_inside_tree():
			higher_chunk.visible = false


# Method to despawn/remove boss
func despawn_boss(boss_node):
	# Remove from nodes
	if mobsLayer.get_node_or_null(boss_node.name) != null:
		mobsLayer.remove_child(boss_node)
		boss_node.queue_free()
		print("----------> Boss \"" + boss_node.name + "\" removed")
