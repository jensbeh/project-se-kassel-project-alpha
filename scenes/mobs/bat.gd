extends KinematicBody2D

# Mobs specific
var health = 100
var damage = 15

# Variables
enum {
	IDLING,
	WANDERING,
	HUNTING
}
var velocity = Vector2(0, 0)
var behaviourState = IDLING

# Mob movment
var acceleration = 350
var friction = 200
var speed = 100
var threshold = 16
var path = []
var navigation : Navigation2D = null

# Nodes
onready var mobSprite = $AnimatedSprite
onready var playerDetectionZone = $PlayerDetectionZone
onready var line2D = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	navigation = owner.navigation
	print(owner.navigation)



func _physics_process(delta):
	match behaviourState:
		IDLING:
			velocity = velocity.move_toward(Vector2(0, 0), friction * delta)
			search_player()

		WANDERING:
			pass

		HUNTING:
			# Check if player is nearby
			if path.size() == 0:
				var player = playerDetectionZone.player
				if player != null:
					generate_path(player.global_position)
				else:
					# Lose player
					behaviourState = IDLING
			# Follow path
			if path.size() > 0:
				move_to_player(delta)

func move_to_player(delta):
	# Stop motion when reached player with little radius
	if global_position.distance_to(path[0]) < threshold:
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
		

func generate_path(player_pos):
	# Get new path to player position
	path = navigation.get_simple_path(global_position, player_pos, false)
	
	# Update line path
	line2D.points = path

func search_player():
	if playerDetectionZone.mob_can_see_player():
		# Player in detection zone of this mob
		behaviourState = HUNTING
