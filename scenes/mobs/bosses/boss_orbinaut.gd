extends "res://scenes/mobs/bosses/boss.gd"


# Nodes
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

# Variables
var is_attacking = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup mob
	# Mob specific
	max_health = 300
	health = 300
	attack_damage = 40
	knockback = 4
	mob_weight = 70
	spawn_time = Constants.SpawnTime.ALWAYS
	max_pre_attack_time = get_new_pre_attack_time(0.0, 2.5)
	
	# Constants
	HUNTING_SPEED = 45
	WANDERING_SPEED = 8
	PRE_ATTACKING_SPEED = 3 * HUNTING_SPEED
	
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
		
		PRE_ATTACKING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 2)
			animationState.start("MOVE")
		
		ATTACKING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 2)
			animationState.start("MOVE")
		
		HURTING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.start("MOVE")
			mob_hurt()
		
		DYING:
			animationTree.set("parameters/MOVE/TimeScale/scale", 1)
			animationState.start("DIE")


func _physics_process(delta):
	# Update parent method
	._physics_process(delta)
	
	# Handle behaviour
	match behaviour_state:
		PRE_ATTACKING:
			# Follow path
			if path.size() > 0:
				move_to_position(delta)
		
		
		ATTACKING:
			# Move mob
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			velocity = move_and_slide(velocity)
			
			if velocity == Vector2.ZERO:
				is_attacking = false
				if playerAttackZone.mob_can_attack:
					update_behaviour(PRE_ATTACKING)
				else:
					update_behaviour(HUNTING)


func _process(delta):
	# Update parent method
	._process(delta)
	
	# Handle behaviour
	match behaviour_state:
		PRE_ATTACKING:
			# Update pre-attack timer so that the mob will wait a specific time before attacking / cooldown
			pre_attack_time += delta
			
			if not mob_need_path:
				if path.size() == 0 and pre_attack_time > max_pre_attack_time:
					pre_attack_time = 0.0
					max_pre_attack_time = get_new_pre_attack_time(0.0, 2.5)
					update_behaviour(ATTACKING)


# Method to update the behaviour of the mob
func update_behaviour(new_behaviour):
	# Update parent method
	.update_behaviour(new_behaviour)
	
	if behaviour_state != new_behaviour:
		# Set previous behaviour state
		previous_behaviour_state = behaviour_state
		
		# Handle new bahaviour
		match new_behaviour:
			PRE_ATTACKING:
				speed = PRE_ATTACKING_SPEED
				if behaviour_state != PRE_ATTACKING:
					# Reset path in case player is seen but e.g. state is wandering
					path.resize(0)
					
					# Update line path
					line2D.points = []
#				print("PRE_ATTACKING")
				behaviour_state = PRE_ATTACKING
				mob_need_path = true
				change_animations(PRE_ATTACKING)
				
				# Disable damagaAreaShape - If the player is too close to the mob, it will not be recognised as new
				damageAreaShape.disabled = true
			
			
			ATTACKING:
				if behaviour_state != ATTACKING:
					# Reset path in case player is seen but e.g. state is wandering
					path.resize(0)
					
					# Update line path
					line2D.points = []
				
				# Move Mob to player and further more
				velocity = global_position.direction_to(Utils.get_current_player().global_position) * 150
				change_animations(ATTACKING)
#				print("ATTACKING")
				behaviour_state = ATTACKING
				mob_need_path = false
				change_animations(ATTACKING)
				
				# Enable damagaAreaShape - If the player is too close to the mob, it will not be recognised as new
				damageAreaShape.disabled = false


func _on_DamageArea_area_entered(area):
	if behaviour_state == ATTACKING and not is_attacking:
		is_attacking = true
		if area.name == "HitboxZone" and area.owner.name == "Player":
			var player = area.owner
			if player.has_method("simulate_damage"):
				var damage = get_attack_damage(attack_damage)
				player.simulate_damage(global_position, damage, knockback)
