extends Node

# Variables
var chunkloader_thread = Thread.new()
var world
var vertical_chunks_count
var horizontal_chunks_count
var map_min_global_pos
var current_player
var current_chunk
var previouse_chunk
var active_chunks = []
var load_chunks = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("START CHUNK_LOADER_SERVICE")

func init(init_world, init_vertical_chunks_count, init_horizontal_chunks_count, init_map_min_global_pos):
	print("INIT CHUNK_LOADER_SERVICE")
	world = init_world
	vertical_chunks_count = init_vertical_chunks_count
	horizontal_chunks_count = init_horizontal_chunks_count
	map_min_global_pos = init_map_min_global_pos
	current_chunk = Utils.get_players_chunk(map_min_global_pos)
	chunkloader_thread.start(self, "load_chunks")
	load_chunks = true


func stop():
	# Reset variables
	call_deferred("cleanup")


func cleanup():
	print("STOP CHUNK_LOADER_SERVICE")
	load_chunks = false
	world = null
	vertical_chunks_count = null
	horizontal_chunks_count = null
	map_min_global_pos = null
	current_chunk = null


func _physics_process(delta):
	if !chunkloader_thread.is_active() and load_chunks:
		current_chunk = Utils.get_players_chunk(map_min_global_pos)
		if previouse_chunk != current_chunk:
			chunkloader_thread.start(self, "load_chunks")
	previouse_chunk = current_chunk


func load_chunks():
	var render_bounds = Constants.render_distance * 2 + 1
	var loading_chunks = []
	for y in range(render_bounds):
		for x in range(render_bounds):
			var chunk_x = current_chunk.x - Constants.render_distance + x
			var chunk_y = current_chunk.y - Constants.render_distance + y
			
			if chunk_x <= horizontal_chunks_count and chunk_y <= vertical_chunks_count:
				var chunk_coords = Vector2(chunk_x, chunk_y)
				loading_chunks.append(chunk_coords)
				
				if active_chunks.find(chunk_coords) == -1:
					# Set chunk to active ones
					active_chunks.append(chunk_coords)
	
	var deleting_chunks = []
	for chunk in active_chunks:
		if loading_chunks.find(chunk) == -1:
			deleting_chunks.append(chunk)
	for chunk in deleting_chunks:
		var index = active_chunks.find(chunk)
		active_chunks.remove(index)
	
	# Make chunks visibel
	call_deferred("send_chunks_to_world", deleting_chunks)
	
	# Update mobs to be active or not
	update_mobs()
	
	call_deferred("task_finished")


func task_finished():
	# Wait for thread to finish
	chunkloader_thread.wait_to_finish()


func update_mobs():
	# Mob lists
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var ambient_mobs = get_tree().get_nodes_in_group("Ambient Mob")
	
	for enemy in enemies:
		var enemy_chunk = Utils.get_chunk_from_position(map_min_global_pos, enemy.global_position)
		if enemy_chunk in active_chunks:
			call_deferred("set_mob_active", enemy, true)
		else:
			call_deferred("set_mob_active", enemy, false)
	
	for ambient_mob in ambient_mobs:
		var ambient_mob_chunk = Utils.get_chunk_from_position(map_min_global_pos, ambient_mob.global_position)
		if ambient_mob_chunk in active_chunks:
			call_deferred("set_mob_active", ambient_mob, true)
		else:
			call_deferred("set_mob_active", ambient_mob, false)


func set_mob_active(mob, is_active):
	if mob != null: # Because scene could be change and/or mob is despawned meanwhile
		mob.call_deferred("set_mob_activity", is_active)


func send_chunks_to_world(deleting_chunks):
	if is_instance_valid(world):
		world.call_deferred("update_chunks", active_chunks, deleting_chunks)
