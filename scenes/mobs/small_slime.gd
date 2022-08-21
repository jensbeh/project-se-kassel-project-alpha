extends "res://scenes/mobs/enemy.gd"


# Nodes
onready var mobSprite = $Sprite
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup mob
	# Mob specific
	max_heath = 100
	health = 100
	attack_damage = 15
	mob_weight = 30
	spawn_time = Constants.SpawnTime.ALWAYS
	
	# Constants
	HUNTING_SPEED = 50
	WANDERING_SPEED = 25
	
	# Animations
	setup_animations()


# Method to setup the animations
func setup_animations():
	# Setup sprite
	mobSprite.flip_h = rng.randi_range(0,1)
	
	# Setup animation
	animationTree.active = true
	animationTree.set("parameters/IDLE/blend_position", velocity)
	animationTree.set("parameters/WALK/blend_position", velocity)


# Method to update the animation with velocity for direction
func update_animations():
	# update sprite direction
	if mobSprite.flip_h != (velocity.x > 0):
		mobSprite.flip_h = velocity.x > 0


# Method to change the animations dependent on behaviour state
func change_animations(animation_behaviour_state):
	# Handle animation_behaviour_state
	match animation_behaviour_state:
		IDLING:
			animationState.start("IDLE")
		
		WANDERING:
			animationState.start("WALK")
		
		HUNTING:
			animationState.start("WALK")
		
		SEARCHING:
			animationState.start("WALK")
		
		HURTING:
			mob_hurt()
		
		DYING:
			animationState.start("DIE")
