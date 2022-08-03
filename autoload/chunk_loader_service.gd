extends Node

# Variables
var chunkloader_thread = Thread.new()
var world
var vertical_chunks_count
var horizontal_chunks_count
var map_min_global_pos
var current_chunk
var previouse_chunk
var active_chunks = []
var can_load_chunks = false


# Called when the node enters the scene tree for the first time.
func _ready():
	print("START CHUNK_LOADER_SERVICE")


# Method to init all important variables
func init(init_world, init_vertical_chunks_count, init_horizontal_chunks_count, init_map_min_global_pos):
	print("INIT CHUNK_LOADER_SERVICE")
	# Check if thread is active wait to stop
	if chunkloader_thread.is_active():
		clean_thread()
	
	# Init variables
	world = init_world
	vertical_chunks_count = init_vertical_chunks_count
	horizontal_chunks_count = init_horizontal_chunks_count
	map_min_global_pos = init_map_min_global_pos
	current_chunk = Utils.get_players_chunk(map_min_global_pos)
	
	# Start chunkloader thread
	chunkloader_thread.start(self, "load_chunks")
	can_load_chunks = true


# Method to stop the chunkloader to change map
func stop():
	# Reset variables
	call_deferred("cleanup")


# Method to cleanup the chunkloader
func cleanup():
	# Check if thread is active wait to stop
	can_load_chunks = false
	if chunkloader_thread.is_active():
		clean_thread()
	
	# Reset variables
	world = null
	vertical_chunks_count = null
	horizontal_chunks_count = null
	map_min_global_pos = null
	current_chunk = null
	active_chunks.clear()
	
	print("STOPPED CHUNK_LOADER_SERVICE")


# Method to load active chunks in background
func load_chunks():
	while can_load_chunks:
		current_chunk = Utils.get_players_chunk(map_min_global_pos)
		if current_chunk == null:
			current_chunk = previouse_chunk
		
		# Generate and update chunks
		if previouse_chunk != current_chunk:
			previouse_chunk = current_chunk
			var render_bounds = Constants.render_distance * 2 + 1
			var loading_chunks = []
			for y in range(render_bounds):
				for x in range(render_bounds):
					var chunk_x = current_chunk.x - Constants.render_distance + x
					var chunk_y = current_chunk.y - Constants.render_distance + y
					
					if chunk_x <= horizontal_chunks_count and chunk_y <= vertical_chunks_count and chunk_x >= 0 and chunk_y >= 0:
						var chunk_coords = Vector2(chunk_x, chunk_y)
						loading_chunks.append(chunk_coords)
						
						if active_chunks.find(chunk_coords) == -1:
							# Set chunk to active ones
							active_chunks.append(chunk_coords)
			
			var deleting_chunks = []
			var new_chunks = active_chunks
			for chunk in new_chunks:
				if loading_chunks.find(chunk) == -1:
					deleting_chunks.append(chunk)
			for chunk in deleting_chunks:
				if new_chunks.find(chunk) != -1:
					var index = new_chunks.find(chunk)
					new_chunks.remove(index)
					
			active_chunks = new_chunks
		
			# Make chunks visibel
			send_chunks_to_world(deleting_chunks)
			
			# Update mobs to be active or not
			update_mobs()


# Method to calculate mob activity
func update_mobs():
	# Mob lists
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var ambient_mobs = get_tree().get_nodes_in_group("Ambient Mob")
	
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.is_inside_tree():
			var enemy_chunk = Utils.get_chunk_from_position(map_min_global_pos, enemy.global_position)
			if enemy_chunk in active_chunks:
				call_deferred("set_mob_activity_state", enemy, true)
			else:
				call_deferred("set_mob_activity_state", enemy, false)
	
	for ambient_mob in ambient_mobs:
		if is_instance_valid(ambient_mob) and ambient_mob.is_inside_tree():
			var ambient_mob_chunk = Utils.get_chunk_from_position(map_min_global_pos, ambient_mob.global_position)
			if ambient_mob_chunk in active_chunks:
				call_deferred("set_mob_activity_state", ambient_mob, true)
			else:
				call_deferred("set_mob_activity_state", ambient_mob, false)


# Method to send mob activity to mob
func set_mob_activity_state(mob, is_active):
	if is_instance_valid(mob) and mob.is_inside_tree(): # Because scene could be change and/or mob is despawned meanwhile
		mob.call_deferred("set_mob_activity", is_active)


# Method to send active and deleted chunks to map to update
func send_chunks_to_world(deleting_chunks):
	if is_instance_valid(world) and world.is_inside_tree():
		world.call_deferred("update_chunks", active_chunks, deleting_chunks)


# Method is called when thread finished
func clean_thread():
	# Wait for thread to finish
	chunkloader_thread.wait_to_finish()
