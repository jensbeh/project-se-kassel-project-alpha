extends Node2D


# Map specific
var scene_type = Constants.SceneType.GRASSLAND
var max_ambient_mobs = 50

# Variables
var thread
var current_area : Area2D = null
var spawning_areas = {}
var ambientMobsSpawnArea
var next_scene_path = ""

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
onready var lootLayer = $map_grassland/entitylayer/lootLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	# Music
	if DayNightCycle.is_night:
		night_sound()
	else:
		day_sound()
	
	var _day = DayNightCycle.connect("change_to_sunrise", self, "day_sound")
	var _day1 = DayNightCycle.connect("change_to_daytime", self, "day_sound")
	var _day2 = DayNightCycle.connect("change_to_sunset", self, "day_sound")
	var _night = DayNightCycle.connect("change_to_night", self, "night_sound")
	
	
	# Setup player
	setup_player()
	
	# Get map informations
	var vertical_chunks_count = groundChunks.get_meta("vertical_chunks_count") - 1
	var horizontal_chunks_count = groundChunks.get_meta("horizontal_chunks_count") - 1
	var map_min_global_pos = groundChunks.get_meta("map_min_global_pos")
	var map_size_in_tiles = groundChunks.get_meta("map_size_in_tiles")
	var map_name = groundChunks.get_meta("map_name")
	
	# Setup ChunkLoaderService
	ChunkLoaderService.init(self, vertical_chunks_count, horizontal_chunks_count, map_min_global_pos)
	
	# Setup areas to change areaScenes
	setup_change_scene_areas()
	
	# Setup stair areas
	setup_stair_areas()
	
	# Setup PathfindingService
	PathfindingService.init(map_name, find_node("astar"), ambientMobsNavigationTileMap, map_size_in_tiles, map_min_global_pos)
	
	# Setup spawning areas
	setup_spawning_areas()
	
	# Spawn random treasures
	spawn_treasures()
	
	# Setup MobSpawnerService
	MobSpawnerService.init(self, scene_type, spawning_areas, mobsNavigationTileMap, mobsLayer, true, ambientMobsSpawnArea, ambientMobsNavigationTileMap, ambientMobsLayer, max_ambient_mobs, true, lootLayer)
	
	# Spawn all mobs
	MobSpawnerService.spawn_mobs()
	
	# Spawn bosses
	spawn_bosses()
	
	# Start PathfindingService
	PathfindingService.start()
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()


func day_sound():
	if Utils.get_music_player().stream != Constants.PreloadedMusic.Grassland:
		Utils.set_and_play_music(Constants.PreloadedMusic.Grassland)
	
func night_sound():
	if Utils.get_music_player().stream != Constants.PreloadedMusic.Night:
		Utils.set_and_play_music(Constants.PreloadedMusic.Night)


# Method to spawn bosses in grassland
func spawn_bosses():
	for current_spawn_area in spawning_areas.keys():
		# Spawn area informations
		var biome_name = spawning_areas[current_spawn_area]["biome"]
		# Generate 2 bosses in mountain
		if biome_name == "mountain":
			for _i in range(2):
				# Take random boss
				var boss_instance = Utils.get_random_boss_preload().instance()
				# Generate spawn position and spawn boss
				boss_instance.init(current_spawn_area, mobsNavigationTileMap, scene_type, false, lootLayer)
				boss_instance.is_boss_in_grassland(true)
				mobsLayer.call_deferred("add_child", boss_instance)
				print("GRASSLAND: Spawned boss \""+ str(boss_instance.name) +"\" in " + str(biome_name))


# Method to destroy the scene
# Is called when SceneManager changes scene after loading new scene
func destroy_scene():
	# Stop pathfinder
	PathfindingService.cleanup()
	
	# Stop chunkloader
	ChunkLoaderService.cleanup()
	
	# Stop mobspawner
	MobSpawnerService.cleanup()
	
	# Disconnect signals
	clear_signals()


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
	
	# Remove scene_player with current_player
	scene_player.get_parent().remove_child(scene_player)
	scene_player.queue_free()
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
	if Utils.get_current_player().is_in_change_scene_area():
		next_scene_path = current_area.get_meta("next_scene_path")
		
		# Handle if change scene is to house
		if Constants.GRASSLAND_BUILDING_FOLDER in next_scene_path:
			# Get door
			var doorArea = find_node(current_area.get_meta("door_id"))
			for child in doorArea.get_children():
				if "animationPlayer" in child.name:
					Utils.set_and_play_sound(Constants.PreloadedSounds.open_door)
					# Start door animation
					child.play("openDoor")
					break
		
		else:
			print("GRASSLAND: Change scene to \""  + str(next_scene_path) + "\"")
			var next_view_direction = Vector2(current_area.get_meta("view_direction_x"), current_area.get_meta("view_direction_y"))
			var transition_data = TransitionData.GameArea.new(next_scene_path, current_area.get_meta("to_spawn_area_id"), next_view_direction)
			Utils.get_scene_manager().transition_to_scene(transition_data)


# Method is called after openDoor animation is finished
func on_door_opened():
	print("GRASSLAND: Change scene with DOOR to \""  + str(next_scene_path) + "\"")
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
			next_scene_path = changeSceneArea.get_meta("next_scene_path")
			print("GRASSLAND: Change scene to \""  + str(next_scene_path) + "\"")
			var next_view_direction = Vector2(changeSceneArea.get_meta("view_direction_x"), changeSceneArea.get_meta("view_direction_y"))
			var transition_data = TransitionData.GameArea.new(next_scene_path, changeSceneArea.get_meta("to_spawn_area_id"), next_view_direction)
			Utils.get_scene_manager().transition_to_scene(transition_data)
		else:
			Utils.get_current_player().set_in_change_scene_area(true)
			current_area = changeSceneArea


# Method which is called when a body has exited a changeSceneArea
func body_exited_change_scene_area(body, changeSceneArea):
	if body.name == "Player":
		print("GRASSLAND: Body \""  + str(body.name) + "\" EXITED changeSceneArea \"" + changeSceneArea.name + "\"")
		current_area = null
		Utils.get_current_player().set_in_change_scene_area(false)


# Setup all stair objectes/Area2D's on start
func setup_stair_areas():
	for chunk in groundChunks.get_children():
		if chunk.has_node("stairs"):
			for stair in chunk.get_node("stairs").get_children():
				if "stairs" in stair.name:
					# connect Area2D with functions to handle body action
					stair.connect("body_entered", self, "body_entered_stair_area", [stair])
					stair.connect("body_exited", self, "body_exited_stair_area", [stair])


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


# Method to disconnect all signals
func clear_signals():
	DayNightCycle.disconnect("change_to_night", self, "night_sound")
	DayNightCycle.disconnect("change_to_sunrise", self, "day_sound")
	DayNightCycle.disconnect("change_to_daytime", self, "day_sound")
	DayNightCycle.disconnect("change_to_sunset", self, "day_sound")
	
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
	
	# Loot & treasures
	for loot in lootLayer.get_children():
		if "treasure" in loot.name:
			loot.clear_signals()
		elif "loot" in loot.name:
			loot.clear_signals()
		else:
			printerr("ERROR: Nothing to disconnect in grassland - clear_signals - loot")


# Method to update the chunks with active and deleted chunks to make them visible or not
func update_chunks(new_chunks : Array, deleting_chunks : Array):
	# Activate chunks
	for chunk in new_chunks:
		var ground_chunk = groundChunks.get_node("Chunk (" + str(chunk.x) + "," + str(chunk.y) + ")")
		if ground_chunk != null and Utils.is_node_valid(ground_chunk):
			ground_chunk.visible = true
		var higher_chunk = higherChunks.get_node("Chunk (" + str(chunk.x) + "," + str(chunk.y) + ")")
		if higher_chunk != null and Utils.is_node_valid(higher_chunk):
			higher_chunk.visible = true
	
	# Disable chunks
	for chunk in deleting_chunks:
		var ground_chunk = groundChunks.get_node("Chunk (" + str(chunk.x) + "," + str(chunk.y) + ")")
		if ground_chunk != null and Utils.is_node_valid(ground_chunk):
			ground_chunk.visible = false
		var higher_chunk = higherChunks.get_node("Chunk (" + str(chunk.x) + "," + str(chunk.y) + ")")
		if higher_chunk != null and Utils.is_node_valid(higher_chunk):
			higher_chunk.visible = false


# Method to despawn/remove boss
func despawn_boss(boss_node):
	# Remove from nodes
	if mobsLayer.get_node_or_null(boss_node.name) != null:
		spawn_loot(boss_node.position, boss_node.get_name())
		yield(boss_node.sound, "finished")
		boss_node.call_deferred("queue_free")
		print("GRASSLAND: Boss \"" + boss_node.name + "\" removed")


# Method to spawn loot after monster died
func spawn_loot(position, mob_name):
	if "Boss" in mob_name:
		var loot = Constants.PreloadedScenes.LootDropScene.instance()
		loot.get_child(0).frame = 187
		loot.init(position, mob_name, false)
		lootLayer.call_deferred("add_child", loot)
	else:
		randomize()
		var random_float = randf()
		if random_float <= Constants.LOOT_CHANCE:
			var loot = Constants.PreloadedScenes.LootDropScene.instance()
			loot.get_child(0).frame = 198
			loot.init(position, mob_name, false)
			lootLayer.call_deferred("add_child", loot)


func spawn_treasures():
	for current_spawn_area in spawning_areas.keys():
		randomize()
		var quantity = randi() % 3
		while quantity != 0:
			# Spawn area informations
			randomize()
			var random_float = randf()
			if random_float <= 0.4:
				# load treasure
				var treasure = Constants.PreloadedScenes.TreasureScene.instance()
				# Generate spawn position and spawn treasure
				treasure.init(current_spawn_area, mobsNavigationTileMap, scene_type, lootLayer)
				lootLayer.call_deferred("add_child", treasure)
			quantity -= 1


# Method is called from MobSpawnerService to instance and spawn the mob -> instancing in other threads causes random errors
func spawn_mob(packedMobScene, current_spawn_area):
	if Utils.is_node_valid(mobsLayer):
		var mob_instance = packedMobScene.instance()
		mob_instance.init(current_spawn_area, mobsNavigationTileMap, scene_type, lootLayer)
		mobsLayer.call_deferred("add_child", mob_instance)
		MobSpawnerService.new_mob_spawned(mob_instance)


# Method is called from MobSpawnerService to instance and spawn the ambient mob -> instancing in other threads causes random errors
func spawn_ambient_mob(mobScene, spawn_time):
	if Utils.is_node_valid(ambientMobsLayer):
		var mob_instance = mobScene.instance()
		mob_instance.init(ambientMobsSpawnArea, ambientMobsNavigationTileMap, spawn_time, scene_type)
		ambientMobsLayer.call_deferred("add_child", mob_instance)
		MobSpawnerService.new_mob_spawned(mob_instance)
