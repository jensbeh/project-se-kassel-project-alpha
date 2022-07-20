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
var navigation : Navigation2D = null
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
	# Wait for owner to be ready
#	yield(get_tree(), "idle_frame")

	# Set spawn_position
	collision_radius = collision.shape.radius
	navigation_tile_map = navigation.get_child(0)
	var spawn_position : Vector2 = Utils.generate_position_in_mob_area(batSpawnArea, navigation_tile_map, collision_radius)
	position = spawn_position

	# Set init max_ideling_time for startstate IDLING
	rng.randomize()
	max_ideling_time = rng.randi_range(0, 8)
	
	# Setup sprite
	mobSprite.flip_h = rng.randi_range(0,1)

func init(init_navigation, init_batSpawnArea):
	navigation = init_navigation
	batSpawnArea = init_batSpawnArea


func _physics_process(delta):
	# Handle behaviourState
	match behaviourState:
		IDLING:
			velocity = velocity.move_toward(Vector2(0, 0), friction * delta)
			search_player()
			
			# After 5 Sec change to WANDERING
			ideling_time += delta
			if ideling_time > max_ideling_time:
				ideling_time = 0.0
				update_behaviour(WANDERING)
				

		WANDERING:
			# Generate wandering path
			if path.size() == 0:
				gernerate_wandering_path()
			# Follow path
			if path.size() > 0:
				move_to_position(delta)
				
			# Check if player is nearby (needs to be at the end of WANDERING)
			search_player()

		HUNTING:
			# Check if player is nearby
			if path.size() == 0:
				var player = playerDetectionZone.player
				if player != null:
					generate_path(player.global_position)
				else:
					# Lose player
					update_behaviour(IDLING)
			# Follow path
			if path.size() > 0:
				move_to_player(delta)


func move_to_player(delta):
	# Remove point when reach with little radius -> take next one
	if global_position.distance_to(path[0]) < player_threshold:
		path.remove(0)
	else:
		# Move Bat
		# Hunting player
		var direction = global_position.direction_to(path[0])
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		velocity = move_and_slide(velocity)
		
		# check if mob can attack
		if playerAttackZone.mob_can_attack:
#			print("ATTACK")
			pass
		
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
		update_behaviour(IDLING)
		line2D.points = []

func generate_path(player_pos):
	# Get new path to player position
	path = navigation.get_simple_path(global_position, player_pos, false)
	
	# Update line path
	line2D.points = path

func search_player():
	if playerDetectionZone.mob_can_see_player():
		# Player in detection zone of this mob
		update_behaviour(HUNTING)
		

func gernerate_wandering_path():
	var wandering_pos = Utils.generate_position_in_mob_area(batSpawnArea, navigation_tile_map, collision_radius)
	
	# Get new path to player position
	path = navigation.get_simple_path(global_position, wandering_pos, false)
	
	# Update line path
	line2D.points = path
	
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
			
			print("IDLING")
			behaviourState = IDLING
			
		WANDERING:
			speed = WANDERING_SPEED
			print("WANDERING")
			behaviourState = WANDERING

		HUNTING:
			speed = HUNTING_SPEED
			
			if behaviourState != HUNTING:
				# Reset path in case player is seen but e.g. state is wandering
				path.resize(0)
				
				# Update line path
				line2D.points = []
			print("HUNTING")
			behaviourState = HUNTING
