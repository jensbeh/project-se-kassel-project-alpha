extends "res://scenes/mobs/enemy.gd"


# Nodes
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

# Variables
var is_attacking = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup mob
	# Mob specific
	enemy_type = EnemyType.GHOST
	max_health = Constants.MobsSettings.GHOST.Health
	health = max_health
	attack_damage = Constants.MobsSettings.GHOST.AttackDamage
	knockback = Constants.MobsSettings.GHOST.Knockback
	mob_weight = Constants.MobsSettings.GHOST.Weight
	experience = Constants.MobsSettings.GHOST.Experience
	spawn_time = Constants.MobsSettings.GHOST.SpawnTime
	min_searching_time = Constants.MobsSettings.GHOST.MinSearchingTime
	max_searching_time = Constants.MobsSettings.GHOST.MaxSearchingTime
	
	# Constants
	HUNTING_SPEED = Constants.MobsSettings.GHOST.HuntingSpeed
	WANDERING_SPEED = Constants.MobsSettings.GHOST.WanderingSpeed
	PRE_ATTACKING_SPEED = Constants.MobsSettings.GHOST.PreAttackingSpeed
	
	# Animations
	setup_animations()


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


# Method to update the view direction with custom value
func set_view_direction(view_direction):
	animationTree.set("parameters/IDLE/blend_position", view_direction)
	animationTree.set("parameters/WALK/blend_position", view_direction)
	animationTree.set("parameters/HURT/blend_position", view_direction)
	animationTree.set("parameters/DIE/blend_position", view_direction)


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
		
		PRE_ATTACKING:
			animationState.start("WALK")
		
		ATTACKING:
			animationState.start("WALK")
		
		HURTING:
			animationState.start("HURT")
		
		DYING:
			animationState.start("DIE")


func _physics_process(delta):
	# Handle behaviour
	match behaviour_state:
		ATTACKING:
			# Move mob
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			velocity = move_and_slide(velocity)
			
			if velocity == Vector2.ZERO:
				is_attacking = false
				if can_attack():
					update_behaviour(PRE_ATTACKING)
				else:
					update_behaviour(HUNTING)


# Method to update the behaviour of the mob
func update_behaviour(new_behaviour):
	# Update firstly parent method
	var updated = .update_behaviour(new_behaviour)
	
	if updated:
		# Handle new bahaviour
		match new_behaviour:
			ATTACKING:
#				print("ATTACKING")
				# Move Mob to player and further more
				velocity = global_position.direction_to(Utils.get_current_player().global_position) * 150


func _on_DamageArea_area_entered(area):
	if behaviour_state == ATTACKING and not is_attacking:
		is_attacking = true
		if area.name == "HitboxZone" and area.owner.name == "Player":
			var player = area.owner
			if player.has_method("simulate_damage"):
				var damage = get_attack_damage(attack_damage)
				player.simulate_damage(global_position, damage, knockback)
