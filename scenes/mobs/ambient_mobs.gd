extends KinematicBody2D

# Mob specific
var spawn_time

# Variables
enum {
	SLEEPING,
	IDLING,
	WANDERING
}
var velocity = Vector2(0, 0)
var behaviour_state = IDLING
var previous_behaviour_state = IDLING
var ambientMobsSpawnArea
var ambientMobsNavigationTileMap : TileMap
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var mob_need_path = false
var update_path_time = 0.0
var max_update_path_time = 0.4
var scene_type

# Constants
const WANDERING_SPEED = 30

# Mob movment
var acceleration = 350
var friction = 200
var speed = WANDERING_SPEED
var wandering_threshold = 5
var path : PoolVector2Array = []
var ideling_time = 0.0
var max_ideling_time

# Nodes
onready var mobSprite = $AnimatedSprite
onready var collision = $Collision
onready var line2D = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set spawn_position
	var spawn_position : Vector2 = Utils.generate_position_in_mob_area(scene_type, ambientMobsSpawnArea, ambientMobsNavigationTileMap, 0, true, null)
	position = spawn_position
	
	# Set init max_ideling_time for startstate IDLING
	rng.randomize()
	max_ideling_time = rng.randi_range(0, 8)
	
	
	# Set here to avoid error "ERROR: FATAL: Index p_index = 30 is out of bounds (count = 30)."
	# Related "https://godotengine.org/qa/142283/game-inconsistently-crashes-what-does-local_vector-h-do"
	call_deferred("set_states_to_nodes")
	
	# Update mobs activity depending on is in active chunk or not
	ChunkLoaderService.call_deferred("update_mob", self)
	
	Utils.count_new_ambient_mob()
	
	MobSpawnerService.call_deferred("new_mob_spawned", self)


# Method to init variables, typically called after instancing
func init(init_ambientMobsSpawnArea, init_ambientMobsNavigationTileMap, init_spawn_time, init_scene_type):
	ambientMobsSpawnArea = init_ambientMobsSpawnArea
	ambientMobsNavigationTileMap = init_ambientMobsNavigationTileMap
	spawn_time = init_spawn_time
	scene_type = init_scene_type


# Method to set states to nodes but not in _ready directly -> called with call_deferred
func set_states_to_nodes():
	# Show or hide nodes for debugging
	collision.set_deferred("visible", Constants.SHOW_AMBIENT_MOB_COLLISION)
	line2D.set_deferred("visible", Constants.SHOW_AMBIENT_MOB_PATHES)
	
	# Setup sprite
	mobSprite.set_deferred("flip_h", rng.randi_range(0,1))


func _physics_process(delta):
	# Handle behaviour
	match behaviour_state:
		IDLING:
			# Mob is doing nothing, just standing
			velocity = velocity.move_toward(Vector2(0, 0), friction * delta)
			
			# After some time change to WANDERING
			ideling_time += delta
			if ideling_time > max_ideling_time:
				ideling_time = 0.0
				update_behaviour(WANDERING)
				
		WANDERING:
			if not mob_need_path:
				# Mob is wandering around
				# Follow wandering path
				if path.size() > 0:
					move_to_position(delta)
				else:
					# Case if pathend is reached, need new path
					update_behaviour(IDLING)


func move_to_position(delta):
	# Stop motion when reached position
	if global_position.distance_to(path[0]) < wandering_threshold:
		path.remove(0)
		
		if Constants.SHOW_AMBIENT_MOB_PATHES:
			# Update line
			line2D.points = path
	else:
		# Move mob
		var direction = global_position.direction_to(path[0])
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		velocity = move_and_slide(velocity)
		
		# update sprite direction
		mobSprite.flip_h = velocity.x > 0
		
		if Constants.SHOW_AMBIENT_MOB_PATHES:
			# Update line position
			line2D.global_position = Vector2(0,0)
	
	if Constants.SHOW_AMBIENT_MOB_PATHES:
		if path.size() == 0:
			line2D.points = []


func update_behaviour(new_behaviour):
	# Set previous behaviour state
	previous_behaviour_state = behaviour_state
	
	# Reset timer
	ideling_time = 0.0
	
	# Handle new bahaviour
	match new_behaviour:
		SLEEPING:
			behaviour_state = SLEEPING
			mob_need_path = false
		
		IDLING:
			# Set new max_ideling_time for IDLING
			rng.randomize()
			max_ideling_time = rng.randi_range(3, 10)
			
#			print("IDLING")
			behaviour_state = IDLING
			mob_need_path = false
		
		WANDERING:
			speed = WANDERING_SPEED
			
			if behaviour_state != WANDERING:
				# Reset path in case player is seen but e.g. state is wandering
				path.resize(0)
				
				if Constants.SHOW_AMBIENT_MOB_PATHES:
					# Update line path
					line2D.points = []
			
#			print("WANDERING")
			behaviour_state = WANDERING
			mob_need_path = true


# Method returns next target position to pathfinding_service
func get_target_position():
	if behaviour_state == WANDERING:
		return Utils.generate_position_in_polygon(ambientMobsSpawnArea, false)


# Method is called from pathfinding_service to set new path to mob
func update_path(new_path):
	# Update mob path
	path = new_path
	mob_need_path = false
	
	if Constants.SHOW_AMBIENT_MOB_PATHES:
		# Update line path
		line2D.points = path


# Method is called from chunk_loader_service to set mob activity
func set_mob_activity(is_active):
	if not is_active and behaviour_state != SLEEPING:
		# Set mob to be sleeping
		update_behaviour(SLEEPING)
	elif is_active and behaviour_state == SLEEPING:
		# wake up the mob to what it has done before
		update_behaviour(previous_behaviour_state)
