extends KinematicBody2D

# Variables
enum {
	IDLING,
	WANDERING
}
var velocity = Vector2(0, 0)
var behaviourState = IDLING
var ambientMobsSpawnArea
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var mob_need_path = false
var update_path_time = 0.0
var max_update_path_time = 0.4

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
	var spawn_position : Vector2 = Utils.generate_position_in_polygon(ambientMobsSpawnArea)
	position = spawn_position

	# Set init max_ideling_time for startstate IDLING
	rng.randomize()
	max_ideling_time = rng.randi_range(0, 8)
	
	# Setup sprite
	mobSprite.flip_h = rng.randi_range(0,1)



# Method to init variables, typically called after instancing
func init(init_ambientMobsSpawnArea):
	ambientMobsSpawnArea = init_ambientMobsSpawnArea

func _physics_process(delta):
	# Handle behaviour
	match behaviourState:
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


# Method returns next target position to pathfinding_service
func get_target_position():
	if behaviourState == WANDERING:
		return Utils.generate_position_in_polygon(ambientMobsSpawnArea)


# Method is called from pathfinding_service to set new path to mob
func update_path(new_path):
	# Update mob path
	path = new_path
	mob_need_path = false
	
	# Update line path
	line2D.points = path
