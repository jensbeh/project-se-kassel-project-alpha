extends "res://scenes/mobs/enemy.gd"

# Nodes
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

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
	animationTree.active = true
	animationState.travel("MOVE")


# Method to change the animations dependent on behaviour state
func change_animations(animation_behaviour_state):
	# Handle animation_behaviour_state
	match animation_behaviour_state:
		IDLING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.travel("MOVE")
		
		WANDERING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.travel("MOVE")
		
		HUNTING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 2)
			animationState.travel("MOVE")
		
		SEARCHING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.travel("MOVE")
		
		HURTING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.travel("MOVE")
			mob_hurt()
		
		DYING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.travel("DIE")
