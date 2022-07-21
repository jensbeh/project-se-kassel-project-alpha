extends KinematicBody2D

# Mob specific
var health = 100
var damage = 15

# Variables
enum {
	IDLING,
	WANDERING,
	HUNTING,
	ATTACKING
}
var velocity = Vector2(0, 0)
var behaviourState = IDLING
var collision_radius
var batSpawnArea
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var mob_need_path = false
var update_path_time = 0.0
var max_update_path_time = 0.4

# Constants
const HUNTING_SPEED = 100
const WANDERING_SPEED = 50

# Mob movment
var acceleration = 350
var friction = 200
var speed = WANDERING_SPEED
var player_threshold = 16
var wandering_threshold = 5
var path : PoolVector2Array = []
var navigation_tile_map
var ideling_time = 0.0
var max_ideling_time

# Nodes
onready var mobSprite = $AnimatedSprite
onready var collision = $Collision
onready var playerDetectionZone = $PlayerDetectionZone
onready var playerAttackZone = $PlayerAttackZone
onready var line2D = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set spawn_position
	collision_radius = collision.shape.radius
	var spawn_position : Vector2 = Utils.generate_position_in_mob_area(batSpawnArea, navigation_tile_map, collision_radius)
	position = spawn_position

	# Set init max_ideling_time for startstate IDLING
	rng.randomize()
	max_ideling_time = rng.randi_range(0, 8)
	
	# Setup sprite
	mobSprite.flip_h = rng.randi_range(0,1)

# Method to init variables, typically called after instancing
func init(init_batSpawnArea, new_navigation_tile_map):
	batSpawnArea = init_batSpawnArea
	navigation_tile_map = new_navigation_tile_map

func _physics_process(delta):
	# Handle behaviour
	match behaviourState:
		IDLING:
			# Mob is doing nothing, just standing and searching for player
			velocity = velocity.move_toward(Vector2(0, 0), friction * delta)
			search_player()
			
			# After 5 Sec change to WANDERING
			ideling_time += delta
			if ideling_time > max_ideling_time:
				ideling_time = 0.0
				update_behaviour(WANDERING)
				
		WANDERING:
			if not mob_need_path:
				# Mob is wandering around and is searching for player
				# Follow wandering path
				if path.size() > 0:
					move_to_position(delta)
				else:
					# Case if pathend is reached, need new path
					update_behaviour(IDLING)
				
			# Check if player is nearby (needs to be at the end of WANDERING)
			search_player()

		HUNTING:
			# Update path generation timer
			update_path_time += delta
			if update_path_time > max_update_path_time:
				update_path_time = 0.0
				mob_need_path = true
			# Check if player is nearby
			var player = playerDetectionZone.player
			if player != null:
				# Follow path
				if path.size() > 0:
					move_to_player(delta)
			else:
				# Lose player
				update_behaviour(IDLING)


		ATTACKING:
			# check if mob can attack
			if !playerAttackZone.mob_can_attack:
				update_behaviour(HUNTING)


func move_to_player(delta):
	# Remove point when reach with little radius -> take next one
	if global_position.distance_to(path[0]) < player_threshold:
		path.remove(0)
		
		# Update line
		line2D.points = path
	else:
		# Move Bat
		# Hunting player
		var direction = global_position.direction_to(path[0])
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		velocity = move_and_slide(velocity)
		
		# check if mob can attack
		if playerAttackZone.mob_can_attack:
			update_behaviour(ATTACKING)
		
		# update sprite direction
		mobSprite.flip_h = velocity.x > 0
		
		# Update line position
		line2D.global_position = Vector2(0,0)
		
	if path.size() == 0:
		line2D.points = []



func move_to_position(delta):
	# Stop motion when reached position
	if global_position.distance_to(path[0]) < wandering_threshold:
		path.remove(0)
		
		# Update line
		line2D.points = path
	else:
		# Move Bat
		var direction = global_position.direction_to(path[0])
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		velocity = move_and_slide(velocity)
		
		# update sprite direction
		mobSprite.flip_h = velocity.x > 0
		
		# Update line position
		line2D.global_position = Vector2(0,0)
		
	if path.size() == 0:
		line2D.points = []

func search_player():
	if playerDetectionZone.mob_can_see_player():
		# Player in detection zone of this mob
		update_behaviour(HUNTING)


func update_behaviour(new_behaviour):
	# Reset timer
	if ideling_time != 0.0:
		ideling_time = 0.0
	
	# Handle new bahaviour
	match new_behaviour:
		IDLING:
			# Set new max_ideling_time for IDLING
			rng.randomize()
			max_ideling_time = rng.randi_range(3, 10)
			
#			print("IDLING")
			behaviourState = IDLING
			mob_need_path = false
			
		WANDERING:
			speed = WANDERING_SPEED
			
			if behaviourState != WANDERING:
				# Reset path in case player is seen but e.g. state is wandering
				path.resize(0)
				
				# Update line path
				line2D.points = []
			
#			print("WANDERING")
			behaviourState = WANDERING
			mob_need_path = true

		HUNTING:
			speed = HUNTING_SPEED
			
			if behaviourState != HUNTING:
				# Reset path in case player is seen but e.g. state is wandering
				path.resize(0)
				
				# Update line path
				line2D.points = []
#			print("HUNTING")
			behaviourState = HUNTING
			mob_need_path = true

		ATTACKING:
			if behaviourState != ATTACKING:
				# Reset path in case player is seen but e.g. state is wandering
				path.resize(0)
				
				# Update line path
				line2D.points = []
#			print("ATTACKING")
			behaviourState = ATTACKING
			mob_need_path = false

# Method returns next target position to pathfinding_service
func get_target_position():
	# Return player hunting position if player is still existing
	if behaviourState == HUNTING:
		var player = playerDetectionZone.player
		if player != null:
			return playerDetectionZone.player.global_position
		else:
			return null
	
	# Return next wandering position
	elif behaviourState == WANDERING:
		return Utils.generate_position_in_mob_area(batSpawnArea, navigation_tile_map, collision_radius)
		

# Method is called from pathfinding_service to set new path to mob
func update_path(new_path):
	# Update mob path
	path = new_path
	mob_need_path = false
	
	# Update line path
	line2D.points = path
