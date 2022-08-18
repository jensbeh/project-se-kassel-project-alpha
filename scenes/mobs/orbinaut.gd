extends "res://scenes/mobs/enemy.gd"

# Nodes
onready var mobSprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	# Animation
	setup_animations()
	
	# Set variables
	# Mob specific
	health = 100
	attack_damage = 15
	spawn_time = Constants.SpawnTime.ONLY_NIGHT
	# Constants
	HUNTING_SPEED = 90
	WANDERING_SPEED = 15


# Method to setup the animations
func setup_animations():
	mobSprite.speed_scale = 1


# Method to change the animations dependent on behaviour state
func change_animations(animation_behaviour_state):
	# Handle animation_behaviour_state
	match animation_behaviour_state:
		IDLING:
			mobSprite.speed_scale = 1
		
		WANDERING:
			mobSprite.speed_scale = 1
		
		HUNTING:
			mobSprite.speed_scale = 2
		
		SEARCHING:
			mobSprite.speed_scale = 1
		
		HURTING:
			mobSprite.speed_scale = 1
		
		DYING:
			mobSprite.speed_scale = 1
