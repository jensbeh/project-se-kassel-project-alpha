extends "res://scenes/mobs/enemy.gd"

# Nodes
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup mob
	# Mob specific
	max_heath = 100
	health = 100
	attack_damage = 15
	mob_weight = 35
	spawn_time = Constants.SpawnTime.ONLY_NIGHT
	
	# Constants
	HUNTING_SPEED = 90
	WANDERING_SPEED = 15
	
	# Animations
	setup_animations()


# Method to setup the animations
func setup_animations():
	animationTree.active = true
	animationState.start("MOVE")


# Method to change the animations dependent on behaviour state
func change_animations(animation_behaviour_state):
	# Handle animation_behaviour_state
	match animation_behaviour_state:
		IDLING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.start("MOVE")
		
		WANDERING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.start("MOVE")
		
		HUNTING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 2)
			animationState.start("MOVE")
		
		SEARCHING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.start("MOVE")
		
		HURTING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.start("MOVE")
			mob_hurt()
		
		DYING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.start("DIE")
