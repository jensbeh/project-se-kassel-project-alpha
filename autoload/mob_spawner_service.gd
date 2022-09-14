extends Node

# Variables
var mobspawner_thread = Thread.new()
var can_spawn_mobs = false
var mob_spawner_timer
var mob_spawn_interval = 20.0 # in sec
var should_spawn_mobs = true
var spawning_areas = null
var mobsNavigationTileMap : TileMap = null
var mobsLayer : Node2D = null
var with_ambient_mobs : bool = false
var mob_list : Array
var ambientMobsSpawnArea = null
var ambientMobsLayer = null
var current_ambient_mobs : int
var max_ambient_mobs : int
var is_time_sensitiv : bool = false
var mobs_to_despawn : Array


# Called when the node enters the scene tree for the first time.
func _ready():
	print("START MOB_SPAWNER_SERVICE")


# Method to init all important variables
func init(new_spawning_areas, new_mobsNavigationTileMap, new_mobsLayer, new_with_ambient_mobs, new_ambientMobsSpawnArea, new_ambientMobsLayer, new_max_ambient_mobs, new_is_time_sensitiv):
	print("INIT MOB_SPAWNER_SERVICE")
	# Check if thread is active wait to stop
	if mobspawner_thread.is_active():
		clean_thread()
	
	# Init variables
	spawning_areas = new_spawning_areas
	mobsNavigationTileMap = new_mobsNavigationTileMap
	mobsLayer = new_mobsLayer
	with_ambient_mobs = new_with_ambient_mobs
	ambientMobsSpawnArea = new_ambientMobsSpawnArea
	ambientMobsLayer = new_ambientMobsLayer
	max_ambient_mobs = new_max_ambient_mobs
	is_time_sensitiv = new_is_time_sensitiv
	# Activate time specific mobs depending on scene_tpye
	if is_time_sensitiv:
		# Connect signals
		var _error1 = DayNightCycle.connect("change_to_sunrise", self, "on_change_to_sunrise")
		var _error2 = DayNightCycle.connect("change_to_night", self, "on_change_to_night")
	
	# Start chunkloader thread
	mobspawner_thread.start(self, "handle_mob_spawns")
	can_spawn_mobs = true
	
	# Create Timer to respawn mobs
	mob_spawner_timer = Timer.new()
	add_child(mob_spawner_timer)
	mob_spawner_timer.connect("timeout", self, "spawn_despawn_mobs")
	mob_spawner_timer.set_wait_time(mob_spawn_interval)
	mob_spawner_timer.start()


# Method to stop the chunkloader to change map
func stop():
	# Reset variables
	call_deferred("cleanup")


# Method to cleanup the chunkloader
func cleanup():
	# Check if thread is active wait to stop
	can_spawn_mobs = false
	should_spawn_mobs = false
	if mobspawner_thread.is_active():
		clean_thread()
	
	# Reset variables
	spawning_areas = null
	mobsNavigationTileMap = null
	mobsLayer = null
	with_ambient_mobs = false
	ambientMobsSpawnArea = null
	ambientMobsLayer = null
	max_ambient_mobs = 0
	mobs_to_despawn.clear()
	# -> Reset timer
	mob_spawner_timer.stop()
	# -> Disconnect signals
	if is_time_sensitiv:
		DayNightCycle.disconnect("change_to_sunrise", self, "on_change_to_sunrise")
		DayNightCycle.disconnect("change_to_night", self, "on_change_to_night")
	# -> Clean mobs
	for mob in mob_list:
		mob.queue_free()
	mob_list.clear()
	
	
	print("STOPPED MOB_SPAWNER_SERVICE")


func spawn_mobs():
	should_spawn_mobs = true


# Method to load active chunks in background
func handle_mob_spawns():
	while can_spawn_mobs:
		if should_spawn_mobs == true:
			should_spawn_mobs = false
			print("----> handle_mob_spawns")
			
			# Despawn mobs if necessary
			if mobs_to_despawn.size() > 0:
				despawn_mobs()
			
			# Spawn area mobs
			spawn_area_mobs()
			
			if with_ambient_mobs:
				# Spawn ambient mobs
				spawn_ambient_mobs()


# Method is called when thread finished
func clean_thread():
	# Wait for thread to finish
	mobspawner_thread.wait_to_finish()


func despawn_mobs():
	var removed_mobs = []
	for mob in mobs_to_despawn:
		# Remove mob if it is not in camera screen
		if not Utils.is_position_in_camera_screen(mob.global_position):
			if mob.is_in_group("Ambient Mob"):
				current_ambient_mobs -= 1
#				print("removed ambient mob: " + str(current_ambient_mobs))
			elif mob.is_in_group("Enemy"):
				spawning_areas[mob.spawnArea]["current_mobs_count"] -= 1
#				print("removed enemy mob: " + str(spawning_areas[mob.spawnArea]["current_mobs_count"]))
			mob.get_parent().call_deferred("remove_child", mob)
			
			if mob in mobs_to_despawn:
				removed_mobs.append(mobs_to_despawn.find(mob))
			
			mob.queue_free()
			mob_list.remove(mob_list.find(mob))
	
	var i = 0
	for removed_mob in removed_mobs:
		mobs_to_despawn.remove(removed_mob - i)
		i += 1
	removed_mobs.clear()


# Method to spawn mobs
func spawn_area_mobs():
	for current_spawn_area in spawning_areas.keys():
		# Spawn area informations
		var biome_mobs_count = spawning_areas[current_spawn_area]["biome_mobs_count"]
		var max_mobs = spawning_areas[current_spawn_area]["max_mobs"]
		var biome_mobs = spawning_areas[current_spawn_area]["biome_mobs"]
		print(spawning_areas[current_spawn_area]["biome_mobs"])
		# Get count of mobs to spawn
		var spawn_mobs_counter = max_mobs - spawning_areas[current_spawn_area]["current_mobs_count"]
		
		print("spawn_mobs_counter: " + str(spawn_mobs_counter))
		
		# Spawn only if needed
		if spawn_mobs_counter > 0:
			var mobs_to_spawn : Array = []
			mobs_to_spawn = Utils.get_spawn_mobs_list(biome_mobs_count, spawn_mobs_counter)
			# Iterate over diffent mobs classes
			for mob in range(biome_mobs.size()):
				# Check if mob should be spawned
				if mob in mobs_to_spawn:
					# Load and spawn mobs
					var mobScene : PackedScene = Constants.PreloadedMobScenes[biome_mobs[mob]]
					
					if mobScene != null:
						# Spawn the mob as often as it is in the list
						for mob_id in mobs_to_spawn:
							if mob == mob_id:
								var mob_instance = mobScene.instance()
								mob_instance.init(current_spawn_area, mobsNavigationTileMap)
								mobsLayer.call_deferred("add_child", mob_instance)
								mob_list.append(mob_instance)
								spawning_areas[current_spawn_area]["current_mobs_count"] += 1
					else:
						printerr("\""+ biome_mobs[mob] + "\" scene can't be loaded!")


# Method to spawn ambient mobs
func spawn_ambient_mobs():
	# Spawn only if needed
	if current_ambient_mobs < max_ambient_mobs:
		# Spawn ambient mobs
		# Check time
		if DayNightCycle.is_night:
			# NIGHT
			# Spawn moths
			var mobScene : Resource = Constants.PreloadedMobScenes["Moth"]
			if mobScene != null:
				while current_ambient_mobs < max_ambient_mobs:
					var mob_instance = mobScene.instance()
					mob_instance.init(ambientMobsSpawnArea, Constants.SpawnTime.ONLY_NIGHT)
					ambientMobsLayer.call_deferred("add_child", mob_instance)
					mob_list.append(mob_instance)
					current_ambient_mobs += 1
			else:
				printerr("\"Moth\" scene can't be loaded!")
		
		else:
			# DAY
			# Spawn butterflies
			var mobScene : Resource = Constants.PreloadedMobScenes["Butterfly"]
			if mobScene != null:
				while current_ambient_mobs < max_ambient_mobs:
					var mob_instance = mobScene.instance()
					mob_instance.init(ambientMobsSpawnArea, Constants.SpawnTime.ONLY_DAY)
					ambientMobsLayer.call_deferred("add_child", mob_instance)
					mob_list.append(mob_instance)
					current_ambient_mobs += 1
			else:
				printerr("\"Butterfly\" scene can't be loaded!")


# Method to despawn/remove mob
func despawn_mob(mob):
	# Remove from variables
	if mob_list.find(mob) != -1:
		mob_list.remove(mob_list.find(mob))
	if mobs_to_despawn.find(mob) != -1:
		mobs_to_despawn.remove(mobs_to_despawn.find(mob))

	# Remove from nodes
	if mobsLayer.get_node_or_null(mob.name) != null:
		spawning_areas[mob.spawnArea]["current_mobs_count"] -= 1
		mobsLayer.remove_child(mob)
		mob.queue_free()
		print("----------> Mob \"" + mob.name + "\" removed")


func spawn_despawn_mobs():
#	remove_mobs(remove_mobs)
	if can_spawn_mobs:
		print("-------------------------> REMOVE MOBS & SPAWN MOBS")
		should_spawn_mobs = true
		mob_spawner_timer.set_wait_time(mob_spawn_interval)
		mob_spawner_timer.start()


# Method to recognize sunrise
func on_change_to_sunrise():
	if can_spawn_mobs:
		# Spawn specific day mobs and remove specific night mobs
		print("day")
		# Remove mobs
		for mob in mob_list:
			if mob.spawn_time == Constants.SpawnTime.ONLY_NIGHT:
				mobs_to_despawn.append(mob)
		# Despawn and spawn mobs
		should_spawn_mobs = true


# Method to recognize night
func on_change_to_night():
	if can_spawn_mobs:
		# Spawn specific night mobs and remove specific day mobs
		print("night")
		# Remove mobs
		for mob in mob_list:
			if mob.spawn_time == Constants.SpawnTime.ONLY_DAY:
				mobs_to_despawn.append(mob)
		# Despawn and spawn mobs
		should_spawn_mobs = true
