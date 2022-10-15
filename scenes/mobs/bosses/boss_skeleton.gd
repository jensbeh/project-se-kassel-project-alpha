extends "res://scenes/mobs/bosses/boss.gd"


# Nodes
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

# Variables
var attack = false
var previouse_player_global_position
var previouse_global_position
var is_attacking = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup mob
	# Mob specific
	max_health = 300
	health = 300
	attack_damage = 40
	knockback = 4
	mob_weight = 100
	spawn_time = Constants.SpawnTime.ALWAYS
	max_pre_attack_time = get_new_pre_attack_time(1.0, 3.0)
	
	# Constants
	HUNTING_SPEED = 25
	WANDERING_SPEED = 20
	PRE_ATTACKING_SPEED = 3 * HUNTING_SPEED
	
	# Animations
	setup_animations()
	
	# Setup healthbar in player_ui if in dungeon
	if is_in_boss_room:
		Utils.get_player_ui().set_boss_name_to_hp_bar(self)


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
			if attack:
				global_position = global_position.move_toward(previouse_player_global_position, delta * 150)
				var view_direction = global_position.direction_to(previouse_player_global_position)
				set_view_direction(view_direction)
				if global_position == previouse_player_global_position:
					attack = false
			else:
				global_position = global_position.move_toward(previouse_global_position, delta * 150)
				var view_direction = global_position.direction_to(previouse_player_global_position)
				set_view_direction(view_direction)
				if global_position == previouse_global_position:
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
				if path.size() == 0:
					# Set view direction to player
					var view_direction = global_position.direction_to(Utils.get_current_player().global_position)
					set_view_direction(view_direction)
				
				if path.size() == 0 and pre_attack_time > max_pre_attack_time:
					pre_attack_time = 0.0
					max_pre_attack_time = get_new_pre_attack_time(1.0, 3.0)
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
					
					if Constants.SHOW_MOB_PATHES:
						# Update line path
						line2D.points = []
#				print("PRE_ATTACKING")
				behaviour_state = PRE_ATTACKING
				mob_need_path = true
				change_animations(PRE_ATTACKING)
				
				# Disable damagaAreaShape - If the player is too close to the mob, it will not be recognised as new
				damageAreaShape.set_deferred("disabled", true)
			
			
			ATTACKING:
				if behaviour_state != ATTACKING:
					# Reset path in case player is seen but e.g. state is wandering
					path.resize(0)
					
					if Constants.SHOW_MOB_PATHES:
						# Update line path
						line2D.points = []
				
				# Move Mob to player and further more
				update_animations()
				attack = true
				previouse_global_position = global_position
				previouse_player_global_position = Utils.get_current_player().global_position
#				print("ATTACKING")
				behaviour_state = ATTACKING
				mob_need_path = false
				change_animations(ATTACKING)
				
				# Enable damagaAreaShape - If the player is too close to the mob, it will not be recognised as new
				damageAreaShape.set_deferred("disabled", false)


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
	return tr("BOSS_SKELETON")
