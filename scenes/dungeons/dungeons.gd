extends Node


# Map specific
var scene_type = Constants.SceneType.DUNGEON

# Variables
var thread
var player_in_change_scene_area = false
var current_area : Area2D = null
var spawning_areas = {}
var groundChunks
var higherChunks
var boss_spawn_area = null

var treasure_dict = {}
var interacted = false
var loot_panel

# Variables - Data passed from scene before
var init_transition_data = null

# Nodes
onready var mobsNavigationTileMap = find_node("mobs_navigation_tilemap")
onready var mobSpawns = find_node("mobSpawns")
onready var mobsLayer = find_node("mobslayer")
onready var lootLayer = find_node("lootLayer")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup player
	setup_player()
	
	# Get map informations
	groundChunks = find_node("groundlayer").get_node("Chunks")
	higherChunks = find_node("higherlayer").get_node("Chunks")
	var vertical_chunks_count = groundChunks.get_meta("vertical_chunks_count") - 1
	var horizontal_chunks_count = groundChunks.get_meta("horizontal_chunks_count") - 1
	var map_min_global_pos = groundChunks.get_meta("map_min_global_pos")
	var map_size_in_tiles = groundChunks.get_meta("map_size_in_tiles")
	var map_name = groundChunks.get_meta("map_name")
	
	# Setup ChunkLoaderService
	ChunkLoaderService.init(self, vertical_chunks_count, horizontal_chunks_count, map_min_global_pos)
	
	# Setup areas to change areaScenes
	setup_change_scene_areas()

	# Setup PathfindingService
	PathfindingService.init(map_name, find_node("astar"), null, map_size_in_tiles, map_min_global_pos)
	
	# Setup spawning areas
	setup_spawning_areas()
	
	# Setup treasures
	setup_treasure_areas()
	
	# Setup MobSpawnerService
	MobSpawnerService.init(scene_type, spawning_areas, mobsNavigationTileMap, mobsLayer, false, null, null, null, 0, false, lootLayer)
	
	# Spawn all mobs
	MobSpawnerService.spawn_mobs()
	
	# Check if boss room
	if is_boss_room():
		# Spawn boss
		spawn_boss()
		
		# Show boss health bar in player ui
		Utils.get_player_ui().show_boss_health_bar(true)
		
		setup_safe_area()
		
		# Handle locked door
		var lockedDoorsNode = find_node("locked_doors")
		var lockedDoorCollisionShape = lockedDoorsNode.find_node("CollisionShape2D")
		PathfindingService.add_dynamic_obstacle(lockedDoorCollisionShape, lockedDoorCollisionShape.get_parent().global_position)
	
	# Start PathfindingService
	PathfindingService.start()
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()


# Method to check if current dungeon is boss room
func is_boss_room() -> bool:
	if find_node("bossSpawn") != null:
		return true
	else:
		return false


# Method to spawn boss in dungeon
func spawn_boss():
	# Take random boss
	var boss_path = Utils.get_random_boss_instance_path()
	var boss_instance = load(boss_path).instance()
	# Generate spawn position and spawn boss
	boss_instance.init(boss_spawn_area, mobsNavigationTileMap, scene_type, is_boss_room(), lootLayer)
	mobsLayer.call_deferred("add_child", boss_instance)


# Method to destroy the scene
# Is called when SceneManager changes scene after loading new scene
func destroy_scene():
	# Check if boss room
	if is_boss_room():
		# Hide boss health bar in player ui
		Utils.get_player_ui().show_boss_health_bar(false)
	
	# Stop pathfinder
	PathfindingService.cleanup()
	
	# Stop chunkloader
	ChunkLoaderService.cleanup()
	
	# Stop mobspawner
	MobSpawnerService.cleanup()
	
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
	Utils.get_current_player().connect("player_interact", self, "interaction")


# Method to set transition_data which contains stuff about the player and the transition
func set_transition_data(transition_data):
	init_transition_data = transition_data


# Method to handle collision detetcion dependent of the collision object type
func interaction_detected():
	if player_in_change_scene_area:
		Utils.get_current_player().set_change_scene(true)
		var next_scene_path = current_area.get_meta("next_scene_path")
		print("-> Change scene \"DUNGEON\" to \""  + str(next_scene_path) + "\"")
		var next_view_direction = Vector2(current_area.get_meta("view_direction_x"), current_area.get_meta("view_direction_y"))
		var transition_data = TransitionData.GameArea.new(next_scene_path, current_area.get_meta("to_spawn_area_id"), next_view_direction)
		Utils.get_scene_manager().transition_to_scene(transition_data)


# Setup all change_scene objectes/Area2D's on start
func setup_change_scene_areas():
	var changeScenesObject = find_node("changeScenes")
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
			print("-> Change scene \"DUNGEON\" to \""  + str(next_scene_path) + "\"")
			var next_view_direction = Vector2(changeSceneArea.get_meta("view_direction_x"), changeSceneArea.get_meta("view_direction_y"))
			var transition_data = TransitionData.GameArea.new(next_scene_path, changeSceneArea.get_meta("to_spawn_area_id"), next_view_direction)
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
func setup_safe_area():
	var safeAreasObject = find_node("safe_area")
	if safeAreasObject != null:
		for child in safeAreasObject.get_children():
			if "safe_area" in child.name:
				# connect Area2D with functions to handle body action
				child.connect("body_entered", self, "body_entered_safe_area", [child])
				child.connect("body_exited", self, "body_exited_safe_area", [child])


# Method which is called when a body has exited a safeArea
func body_entered_safe_area(body, safeArea):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" ENTERED safeArea \"" + safeArea.name + "\"")
		Utils.get_current_player().set_in_safe_area(true)


# Method which is called when a body has exited a safeArea
func body_exited_safe_area(body, safeArea):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" EXITED safeArea \"" + safeArea.name + "\"")
		Utils.get_current_player().set_in_safe_area(false)


# Method to disconnect all signals
func clear_signals():
	# Player
	Utils.get_current_player().disconnect("player_interact", self, "interaction_detected")
	Utils.get_current_player().disconnect("player_interact", self, "interaction")
	
	# Change scene areas
	var changeScenesObject = find_node("changeScenes")
	for child in changeScenesObject.get_children():
		if "changeScene" in child.name:
			# connect Area2D with functions to handle body action
			child.disconnect("body_entered", self, "body_entered_change_scene_area")
			child.disconnect("body_exited", self, "body_exited_change_scene_area")
	
	# Treasures
	for chunk in groundChunks.get_children():
		var treasure_object = chunk.find_node("treasures")
		if treasure_object != null:
			for treasure_node in treasure_object.get_children():
				# Find area in treasure_node
				var treasure_area = null
				for child in treasure_node.get_children():
					if child is Area2D:
						treasure_area = child
						break
				
				if treasure_area != null:
					# connect Area2D with functions to handle body action
					treasure_area.disconnect("body_entered", self, "body_entered_treasure")
					treasure_area.disconnect("body_exited", self, "body_exited_treasure")
	
	# Safeareas
	var safeAreasObject = find_node("safe_area")
	if safeAreasObject != null:
		for child in safeAreasObject.get_children():
			if "safe_area" in child.name:
				# connect Area2D with functions to handle body action
				child.disconnect("body_entered", self, "body_entered_safe_area")
				child.disconnect("body_exited", self, "body_exited_safe_area")


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
	
	# Check if is boss room to generate boss spawning area
	if is_boss_room():
		var boss_area = find_node("bossSpawn").get_child(0)
		boss_spawn_area = Utils.generate_mob_spawn_area_from_polygon(boss_area.position, boss_area.get_child(0).polygon)


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
		boss_node.call_deferred("queue_free")
		print("----------> Boss \"" + boss_node.name + "\" removed")
	
	# Disable mobs respawning
	MobSpawnerService.disable_mob_respawning(true)


# Method is called from boss on death when key to open the door should be spawned
func spawn_key_at_death(death_position):
	var key_instance = load("res://scenes/items/golden_key.tscn").instance()
	key_instance.init(death_position)
	find_node("keylayer").call_deferred("add_child", key_instance)


# Method is called from golden key when player collected it
func on_key_collected():
	# Remove locked door
	var lockedDoorsNode = find_node("locked_doors")
	for child in lockedDoorsNode.get_children():
		child.call_deferred("queue_free")


# Method to spawn loot after monster died
func spawn_loot(position, mob_name):
	if "Boss" in mob_name:
		var loot = load(Constants.LOOT_DROP_PATH).instance()
		loot.get_child(0).frame = 187
		loot.init(position, mob_name, true)
		lootLayer.call_deferred("add_child", loot)
	else:
		randomize()
		var random_float = randf()
		if random_float <= Constants.LOOT_CHANCE:
			var loot = load(Constants.LOOT_DROP_PATH).instance()
			loot.get_child(0).frame = 198
			loot.init(position, mob_name, true)
			lootLayer.call_deferred("add_child", loot)


# Method which is called when a body has entered a treasure Area
func body_entered_treasure(body, treasureArea):
	if body.name == "Player":
		treasure_dict[treasureArea][0] = true

# Method which is called when a body has exited a treasure Area
func body_exited_treasure(body, treasureArea):
	if body.name == "Player":
		treasure_dict[treasureArea][0] = false
		interacted = false


# Setup all treasure objectes/Area2D's on start
func setup_treasure_areas():
	for chunk in groundChunks.get_children():
		var treasure_object = chunk.find_node("treasures")
		if treasure_object != null:
			randomize()
			var treasures_to_delete = []
			for treasure_node in treasure_object.get_children():
				# Skip treasure if it is broken object
				if treasure_node.get_child_count() == 0:
					continue
				
				var random_float = randf()
				
				# Remove existing treasure_node (add to list to remove after iteration)
				if random_float >= Constants.LOOT_CHANCE and !treasure_node.get_meta("boss_loot"):
					treasures_to_delete.append(treasure_node)
				
				# Keep existing treasure_node
				else:
					var treasure_data = []
					treasure_data.append(false) # in range
					treasure_data.append(false) # looted
					treasure_data.append({}) # loot list
					treasure_data.append(treasure_node.get_meta("selected_treasure_sprite")) # treasure type
					
					# Find area in treasure_node
					var treasure_area = null
					for child in treasure_node.get_children():
						if child is Area2D:
							treasure_area = child
							break
					
					if treasure_area != null:
						treasure_dict[treasure_area] = treasure_data
						# connect Area2D with functions to handle body action
						treasure_area.connect("body_entered", self, "body_entered_treasure", [treasure_area])
						treasure_area.connect("body_exited", self, "body_exited_treasure", [treasure_area])
					else:
						printerr("Error in dungeons - setup_treasure_areas -> treasure_area is null")
					
					
					# Add treasure to obstacles
					# Find collision_shape and position of treasure
					var treasure_collision = null
					var treasure_position = Vector2.ZERO
					for child in treasure_node.get_children():
						if child is StaticBody2D:
							treasure_position = child.position
							treasure_collision = child.get_child(0)
							break
					PathfindingService.add_dynamic_obstacle(treasure_collision, treasure_position)
			
			# Delete treasure_nodes which should be removed
			for treasure_to_delete in treasures_to_delete:
				treasure_to_delete.call_deferred("queue_free")
			
			# Delete treasure_object if there are no more treasure_nodes
			if treasure_object.get_child_count() == 0:
				treasure_object.call_deferred("queue_free")


# when interacted, open dialog
func interaction():
	var treasure
	for i in treasure_dict.keys():
		if treasure_dict[i][0]:
			treasure = i
	if treasure != null:
		if treasure_dict[treasure][0] and !interacted:
			interacted = true
			Utils.get_current_player().set_movement(false)
			Utils.get_current_player().set_player_can_interact(false)
			var dialog = load(Constants.DIALOG_PATH).instance()
			Utils.get_ui().add_child(dialog)
			if !treasure_dict[treasure][1]:
				if treasure_dict[treasure][3] == 3:
					dialog.start(treasure, treasure_dict[treasure][1], "")
				else:
					dialog.start(treasure, treasure_dict[treasure][1], str(treasure_dict[treasure][3]))
			elif treasure_dict[treasure][2].empty():
				if treasure_dict[treasure][3] == 3:
					dialog.start(treasure, treasure_dict[treasure][1], "")
				else:
					dialog.start(treasure, treasure_dict[treasure][1], str(treasure_dict[treasure][3]))
			else:
				dialog.start(treasure, "open", "")


func reset_interaction():
	interacted = false


# called to open the loot panel
func open_loot_panel(treasure):
	interacted = true
	loot_panel = (load(Constants.LOOT_PANEL_PATH).instance())
	Utils.get_ui().add_child(loot_panel)
	loot_panel.connect("looted", self, "save_loot")
	if !treasure_dict[treasure][1]:
		treasure_dict[treasure][1] = true
		for child in treasure.get_children():
			if "animationPlayer" in child.name:
				# Start treasure animation
				child.play("openTreasure")
		loot_panel.set_loot_type("Treasure" + str(treasure_dict[treasure][3]), true)
		loot_panel.loot()
	else:
		loot_panel.set_up_content(treasure_dict[treasure][2])


func save_loot(loot):
	var treasure
	for i in treasure_dict.keys():
		if treasure_dict[i][0]:
			treasure = i
	interacted = false
	treasure_dict[treasure][2] = loot
	loot_panel.disconnect("looted", self, "save_loot")


# check if the player has a key to open the cheest
func player_has_key(treasureArea):
	if treasure_dict[treasureArea][1]:
		return true
	elif treasure_dict[treasureArea][3] == 1:
		for i in range(1,31):
			if PlayerData.inv_data["Inv" + str(i)]["Item"] == 10022:
				if PlayerData.inv_data["Inv" + str(i)]["Stack"] > 1:
					PlayerData.inv_data["Inv" + str(i)]["Stack"] -= 1
				else:
					PlayerData.inv_data["Inv" + str(i)]["Item"] = null
				return true
		return false
	elif treasure_dict[treasureArea][3] == 2:
		for i in range(1,31):
			if PlayerData.inv_data["Inv" + str(i)]["Item"] == 10023:
				if PlayerData.inv_data["Inv" + str(i)]["Stack"] > 1:
					PlayerData.inv_data["Inv" + str(i)]["Stack"] -= 1
				else:
					PlayerData.inv_data["Inv" + str(i)]["Item"] = null
				return true
		return false
	else:
		return true
