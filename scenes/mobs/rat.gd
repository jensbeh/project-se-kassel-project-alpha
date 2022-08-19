extends "res://scenes/mobs/enemy.gd"


# Nodes
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set variables
	# Mob specific
	health = 100
	attack_damage = 15
	mob_weight = 10
	spawn_time = Constants.SpawnTime.ONLY_NIGHT
	# Constants
	HUNTING_SPEED = 70
	WANDERING_SPEED = 40


# Method to setup the animations
func setup_animations():
	animationTree.active = true
	update_animations()


# Method to update the animation with velocity for direction
func update_animations():
	animationTree.set("parameters/IDLE/blend_position", velocity)
	animationTree.set("parameters/WALK/blend_position", velocity)
	animationTree.set("parameters/HURT/blend_position", velocity)
	animationTree.set("parameters/DIE/blend_position", velocity)


# Method to change the animations dependent on behaviour state
func change_animations(animation_behaviour_state):
	# Handle animation_behaviour_state
	match animation_behaviour_state:
		IDLING:
			animationState.travel("IDLE")
		
		WANDERING:
			animationState.travel("WALK")
		
		HUNTING:
			animationState.travel("WALK")
		
		SEARCHING:
			animationState.travel("WALK")
		
		HURTING:
			animationState.travel("HURT")
		
		DYING:
			animationState.travel("DIE")
