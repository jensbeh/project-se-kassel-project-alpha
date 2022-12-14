extends "res://scenes/mobs/enemy.gd"


# Nodes
onready var mobSprite = $Sprite

# Variables
var is_attacking = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup mob
	# Mob specific
	enemy_type = EnemyType.SMALL_SLIME
	max_health = Constants.MobsSettings.SMALL_SLIME.Health
	health = max_health
	attack_damage = Constants.MobsSettings.SMALL_SLIME.AttackDamage
	knockback = Constants.MobsSettings.SMALL_SLIME.Knockback
	mob_weight = Constants.MobsSettings.SMALL_SLIME.Weight
	experience = Constants.MobsSettings.SMALL_SLIME.Experience
	spawn_time = Constants.MobsSettings.SMALL_SLIME.SpawnTime
	min_searching_time = Constants.MobsSettings.SMALL_SLIME.MinSearchingTime
	max_searching_time = Constants.MobsSettings.SMALL_SLIME.MaxSearchingTime
	
	# Constants
	HUNTING_SPEED = Constants.MobsSettings.SMALL_SLIME.HuntingSpeed
	WANDERING_SPEED = Constants.MobsSettings.SMALL_SLIME.WanderingSpeed
	PRE_ATTACKING_SPEED = Constants.MobsSettings.SMALL_SLIME.PreAttackingSpeed
	
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


# Method to update the view direction with custom value
func set_view_direction(view_direction):
	# update sprite direction
	if mobSprite.flip_h != (view_direction.x > 0):
		mobSprite.flip_h = view_direction.x > 0


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
			mob_hurt()
		
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
