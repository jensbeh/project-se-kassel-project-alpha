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
	boss_type = BossType.BOSS_ORBINAUT
	max_health = Constants.BossesSettings.BOSS_ORBINAUT.Health
	health = max_health
	attack_damage = Constants.BossesSettings.BOSS_ORBINAUT.AttackDamage
	knockback = Constants.BossesSettings.BOSS_ORBINAUT.Knockback
	mob_weight = Constants.BossesSettings.BOSS_ORBINAUT.Weight
	experience = Constants.BossesSettings.BOSS_ORBINAUT.Experience
	spawn_time = Constants.BossesSettings.BOSS_ORBINAUT.SpawnTime
	min_searching_time = Constants.BossesSettings.BOSS_ORBINAUT.MinSearchingTime
	max_searching_time = Constants.BossesSettings.BOSS_ORBINAUT.MaxSearchingTime
	
	# Constants
	HUNTING_SPEED = Constants.BossesSettings.BOSS_ORBINAUT.HuntingSpeed
	WANDERING_SPEED = Constants.BossesSettings.BOSS_ORBINAUT.WanderingSpeed
	PRE_ATTACKING_SPEED = Constants.BossesSettings.BOSS_ORBINAUT.PreAttackingSpeed
	
	# Animations
	setup_animations()
	
	# Setup healthbar in player_ui if in dungeon
	if is_in_boss_room:
		Utils.get_player_ui().set_boss_name_to_hp_bar(self)


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


# Method to return boss name
func get_boss_name():
	return tr("BOSS_ORBINAUT")
