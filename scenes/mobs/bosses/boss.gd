extends KinematicBody2D

# Constants
var DETECTION_RADIUS_IN_GRASSLAND = Constants.BossesSettings.GENERAL.DetectionRadiusInGrassland
var DETECTION_RADIUS_IN_DUNGEON = Constants.BossesSettings.GENERAL.DetectionRadiusInDungeon
var ATTACK_RADIUS_IN_GRASSLAND = Constants.BossesSettings.GENERAL.AttackRadiusInGrassland
var ATTACK_RADIUS_IN_DUNGEON = Constants.BossesSettings.GENERAL.AttackRadiusInDungeon
var HUNTING_SPEED
var WANDERING_SPEED
var PRE_ATTACKING_SPEED
var REGENERATION_HP_AMOUNT
var CANT_REACH_DISTANCE = ATTACK_RADIUS_IN_GRASSLAND # Set here but will be overwritten in _ready
var DIRECT_ATTACK_STYLE_PROBABILITY = Constants.BossesSettings.GENERAL.DirectAttackStyleProbability # var = direct pre attack probability //// 1 - var = area pre attack probability

enum BossType {
	BOSS_FUNGUS,
	BOSS_GHOST,
	BOSS_ORBINAUT,
	BOSS_SKELETON,
	BOSS_SMALL_SLIME,
	BOSS_ZOMBIE
}

# Mob specific
var max_health
var health
var attack_damage
var knockback
var spawn_time = Constants.SpawnTime.ALWAYS
var mob_weight
var experience
var boss_type

# Variables
var boss_spawn_area
enum {
	SLEEPING,
	IDLING,
	SEARCHING,
	WANDERING,
	HUNTING,
	HURTING,
	DYING,
	PRE_ATTACKING,
	ATTACKING,
	CANT_REACH_PLAYER,
}
var velocity = Vector2(0, 0)
var behaviour_state = IDLING
var previous_behaviour_state = IDLING
var collision_radius
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var mob_need_path = false
var update_path_time = 0.0
var max_update_path_time = 0.4
var max_searching_radius
var min_searching_radius
var start_searching_position
var max_attacking_radius_around_player
var min_attacking_radius_around_player
var pre_attack_time = 0.0
var max_pre_attack_time
var in_grassland = false
var regenerate_hp = false
var regeneration_interval = 0.0
var max_regeneration_interval
var scene_type
var is_in_boss_room
var lootLayer
var killed = false
var update_get_target_position = false
var new_position_dic : Dictionary = {}
var check_can_reach_player = false
var attack_radius
var is_directly_attacking = false

# Mob movment
var acceleration = 350
var friction = 200
var speed = WANDERING_SPEED
var position_threshold = 5
var path : PoolVector2Array = []
var navigation_tile_map
var ideling_time = 0.0
var max_ideling_time
var searching_time = 0.0
var current_max_searching_time = 0.0
var min_searching_time
var max_searching_time

# Nodes
onready var collision = $Collision
onready var playerDetectionZone = $PlayerDetectionZone
onready var playerDetectionZoneShape = $PlayerDetectionZone/DetectionShape
onready var damageArea = $DamageArea
onready var damageAreaShape = $DamageArea/CollisionShape2D
onready var line2D = $Line2D
onready var hitbox = $HitboxZone
onready var healthBar = $NinePatchRect/ProgressBar
onready var healthBarNode = $NinePatchRect
onready var raycast = $RayCast2D
onready var sound = get_node("HitboxZone/Sound")


# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().audio_listener_enable_2d = true
	# Show or hide nodes for debugging
	collision.visible = Constants.SHOW_BOSS_COLLISION
	playerDetectionZone.visible = Constants.SHOW_BOSS_DETECTION_RADIUS
	line2D.visible = Constants.SHOW_BOSS_PATHES
	hitbox.visible = Constants.SHOW_BOSS_HITBOX
	damageArea.visible = Constants.SHOW_BOSS_DAMAGE_AREA
	
	
	# Set detection and attack radius depending on grassland or not
	if in_grassland:
		playerDetectionZoneShape.shape.radius = DETECTION_RADIUS_IN_GRASSLAND
		attack_radius = ATTACK_RADIUS_IN_GRASSLAND
		CANT_REACH_DISTANCE = ATTACK_RADIUS_IN_GRASSLAND
	else:
		playerDetectionZoneShape.shape.radius = DETECTION_RADIUS_IN_DUNGEON
		attack_radius = ATTACK_RADIUS_IN_DUNGEON
		CANT_REACH_DISTANCE = ATTACK_RADIUS_IN_DUNGEON
	
	
	# Set spawn position
	collision_radius = collision.shape.radius
	var spawn_position : Vector2 = Utils.generate_position_in_mob_area(scene_type, boss_spawn_area, navigation_tile_map, collision_radius, true, lootLayer, 3)
	position = spawn_position
	
	
	# Set init max_ideling_time for startstate IDLING
	rng.randomize()
	max_ideling_time = rng.randi_range(0, 8)
	
	
	# Setup initial mob view direction
	velocity = Vector2(rng.randi_range(-1,1), rng.randi_range(-1,1))
	
	
	# Setup searching variables
	max_searching_radius = playerDetectionZoneShape.shape.radius
	min_searching_radius = max_searching_radius * 0.33
	
	
	# Setup Healthbar
	healthBar.value = 100
	healthBarNode.visible = false
	max_regeneration_interval = 0.1 # every 0.1 sek
	REGENERATION_HP_AMOUNT = 20 * max_regeneration_interval  # 20 health every 1 sec == 2 health every max_regeneration_interval
	
	
	# Setup attacking radius around player variables
	randomize()
	max_attacking_radius_around_player = attack_radius * rand_range(0.9, 1.0)
	min_attacking_radius_around_player = attack_radius * rand_range(0.75, 0.85)
	
	# Enable raycast
	raycast.enabled = true
	
	
	# Update mobs activity depending on is in active chunk or not
	ChunkLoaderService.update_mob(self)


# Method to init variables, typically called after instancing
func init(init_boss_spawn_area, init_navigation_tile_map, init_scene_type, init_is_in_boss_room, init_lootLayer):
	boss_spawn_area = init_boss_spawn_area
	navigation_tile_map = init_navigation_tile_map
	scene_type = init_scene_type
	is_in_boss_room = init_is_in_boss_room
	lootLayer = init_lootLayer


func _physics_process(delta):
	# Handle position update
	if update_get_target_position:
		# Handle behaviour
		match behaviour_state:
			
			# Return player hunting position if player is still existing
			HUNTING:
#				print("HUNTING")
				var player = playerDetectionZone.player
				if player != null:
					PathfindingService.call_deferred("got_boss_position", self, playerDetectionZone.player.global_position)
					update_get_target_position = false
			
			
			# Return next wandering position
			WANDERING:
#				print("WANDERING")
				var new_position = Vector2.ZERO
				new_position = Utils.generate_position_in_mob_area(scene_type, boss_spawn_area, navigation_tile_map, collision_radius, false, lootLayer, 3)
				PathfindingService.call_deferred("got_boss_position", self, new_position)
				update_get_target_position = false
			
			
			# Return next searching position
			SEARCHING:
#				print("SEARCHING")
				if not new_position_dic.empty() and not new_position_dic["generate_again"]:
					raycast.cast_to = new_position_dic["position"] - global_position
					raycast.force_raycast_update()
					
					if not raycast.is_colliding():
						PathfindingService.call_deferred("got_boss_position", self, new_position_dic["position"])
						update_get_target_position = false
#					else:
#						printerr("SEARCHING: GENERATE POSITION AGAIN -> RAYCAST.IS_COLLIDING: " + str(raycast.get_collider()))
					new_position_dic.clear()
			
			
			CANT_REACH_PLAYER:
#				print("CANT_REACH_PLAYER")
				var new_position = Vector2.ZERO
				new_position = Utils.generate_position_in_mob_area(scene_type, boss_spawn_area, navigation_tile_map, collision_radius, false, lootLayer, 3)
				PathfindingService.call_deferred("got_boss_position", self, new_position)
				update_get_target_position = false
			
			
			PRE_ATTACKING:
#				print("PRE_ATTACKING")
				if not new_position_dic.empty() and not new_position_dic["generate_again"]:
					raycast.cast_to = new_position_dic["position"] - global_position
					raycast.force_raycast_update()
					if not raycast.is_colliding():
						PathfindingService.call_deferred("got_boss_position", self, new_position_dic["position"])
						update_get_target_position = false
					else:
#						printerr("PRE_ATTACKING: RAYCAST.IS_COLLIDING")
						update_behaviour(HUNTING)
					
					new_position_dic.clear()
			
			
			ATTACKING:
				raycast.cast_to = Utils.get_current_player().global_position - global_position
				raycast.force_raycast_update()
				if raycast.is_colliding():
					update_behaviour(HUNTING)
#					printerr("ATTACKING: RAYCAST.IS_COLLIDING")
	
	
	# Handle behaviour
	match behaviour_state:
		
		IDLING:
			# Mob is doing nothing, just standing and searching for player
			velocity = velocity.move_toward(Vector2(0, 0), friction * delta)
			
			search_player()
		
		
		WANDERING:
			if not mob_need_path:
				# Mob is wandering around and is searching for player
				# Follow wandering path
				if path.size() > 0:
					move_to_position(delta)
			
			# Check if player is nearby (needs to be at the end of WANDERING)
			search_player()
		
		
		HUNTING:
			# Check if player is nearby
			var player = playerDetectionZone.player
			if player != null:
				# Follow path
				if path.size() > 0:
					move_to_position(delta)
				
				if can_attack():
					update_behaviour(PRE_ATTACKING)
		
		
		SEARCHING:
			if not mob_need_path:
				# Mob is wandering around and is searching for player
				# Follow searching path
				if path.size() > 0:
					move_to_position(delta)
			
			# Mob is doing nothing, just standing and searching for player
			search_player()
		
		
		CANT_REACH_PLAYER:
			if not mob_need_path:
				# Mob is wandering around and is searching for player
				# Follow wandering path
				if path.size() > 0:
					move_to_position(delta)
			
			# Check if player is nearby (needs to be at the end of CANT_REACH_PLAYER)
			search_player()
		
		
		PRE_ATTACKING:
			if not can_attack():
				update_behaviour(HUNTING)
			
			else:
				# Follow path
				if path.size() > 0:
					move_to_position(delta)
		
		
		HURTING:
			# handle knockback
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			velocity = move_and_slide(velocity)
		
		
		DYING:
			# handle knockback
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			velocity = move_and_slide(velocity)
	
	
	# Regenerate hp bar if enabled
	if regenerate_hp:
		regenerate_hp_bar(delta)


func _process(delta):
	# Handle position update
	if update_get_target_position:
		# Handle behaviour
		match behaviour_state:
			SEARCHING:
#				print("SEARCHING")
				if new_position_dic.empty() or new_position_dic["generate_again"]:
					new_position_dic = Utils.generate_position_near_mob(scene_type, start_searching_position, min_searching_radius, max_searching_radius, navigation_tile_map, collision_radius)
			
			PRE_ATTACKING:
#				print("PRE_ATTACKING")
				if new_position_dic.empty() or new_position_dic["generate_again"]:
					# Choose position
					if is_directly_attacking:
						# DIRECT: Position between player and mob
						var player_pos : Vector2 = Utils.get_current_player().global_position
						var direction : Vector2 = player_pos.direction_to(global_position).normalized()
						var end_pos : Vector2 = player_pos + attack_radius * direction
						
						new_position_dic = {
											"generate_again": false,
											"position": end_pos
											}
					
					else:
						# AREA: Take position around player
						new_position_dic = Utils.generate_position_near_mob(scene_type, Utils.get_current_player().global_position, min_attacking_radius_around_player, max_attacking_radius_around_player, navigation_tile_map, collision_radius)
					
#					print("GENERATE NEW POSITION for PRE_ATTACKING")
	
	
	# Handle behaviour
	match behaviour_state:
		
		IDLING:
			# After some time change to WANDERING
			ideling_time += delta
			if ideling_time > max_ideling_time:
				ideling_time = 0.0
				update_behaviour(WANDERING)
		
		
		WANDERING:
			if not mob_need_path:
				# Mob is wandering around and is searching for player
				# Follow wandering path
				if path.size() == 0:
					# Case if pathend is reached, need new path
					update_behaviour(IDLING)
		
		
		HUNTING:
			# Update path generation timer
			update_path_time += delta
			if update_path_time > max_update_path_time:
				update_path_time = 0.0
				mob_need_path = true
			# Check if player is nearby
			var player = playerDetectionZone.player
			if player == null:
				# Lose player
				update_behaviour(SEARCHING)
		
		
		SEARCHING:
			if not mob_need_path:
				# Mob is wandering around and is searching for player
				# Follow searching path
				if path.size() > 0:
					# After some time change to WANDERING (also to return to mob area)
					searching_time += delta
					if searching_time > current_max_searching_time:
						searching_time = 0.0
						update_behaviour(WANDERING)
				else:
					# Case if pathend is reached, need new path for searching
					mob_need_path = true
		
		
		PRE_ATTACKING:
			# Update pre-attack timer so that the mob will wait a specific time before attacking / cooldown
			pre_attack_time += delta
			
			if not mob_need_path:
				if path.size() == 0:
					# Set view direction to player
					var view_direction = global_position.direction_to(Utils.get_current_player().global_position)
					set_view_direction(view_direction)
				
				if path.size() == 0 and pre_attack_time > max_pre_attack_time:
					update_behaviour(ATTACKING)


# Method to move the mob to position
func move_to_position(delta):
	# Stop motion when reached position
	if global_position.distance_to(path[0]) < position_threshold:
		path.remove(0)
		
		if Constants.SHOW_BOSS_PATHES:
			# Update line
			line2D.points = path
	else:
		# Move mob
		var direction = global_position.direction_to(path[0])
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		velocity = move_and_slide(velocity)
		# Update anmination
		update_animations()
		
		if Constants.SHOW_BOSS_PATHES:
			# Update line position
			line2D.global_position = Vector2(0,0)
	
	if Constants.SHOW_BOSS_PATHES:
		if path.size() == 0:
			line2D.points = []


# Method to search for player
func search_player():
	# Check if player is nearby the mob
	if playerDetectionZone.mob_can_see_player():
		# Case if mob can reach player
		if behaviour_state != CANT_REACH_PLAYER:
			# Check if mob can "see" player
			raycast.cast_to = Utils.get_current_player().global_position - global_position
			raycast.force_raycast_update()
			
			if not raycast.is_colliding():
				# Player in detection zone of this mob and mob can "see" player
				update_behaviour(HUNTING)
#			else:
#				printerr("SEARCHING - COLLIDING: " + str(raycast.get_collider()))
	
	
	else:
		# Case if player no longer in detection zone and player was not reachable
		if behaviour_state == CANT_REACH_PLAYER:
			check_can_reach_player = false
			update_behaviour(WANDERING)


# Method to update the behaviour of the mob
func update_behaviour(new_behaviour):
	var updated = false # To avoid multiple updates in subclasses if behaviour_state was == new_behaviour
	if behaviour_state != new_behaviour:
		updated = true
		
		# Set previous behaviour state
		previous_behaviour_state = behaviour_state
		
#		match new_behaviour:
#			0:
#				print("new_behaviour: SLEEPING")
#			1:
#				print("new_behaviour: IDLING")
#			2:
#				print("new_behaviour: SEARCHING")
#			3:
#				print("new_behaviour: WANDERING")
#			4:
#				print("new_behaviour: HUNTING")
#			5:
#				print("new_behaviour: HURTING")
#			6:
#				print("new_behaviour: DYING")
#			7:
#				print("new_behaviour: PRE_ATTACKING")
#			8:
#				print("new_behaviour: ATTACKING")
#			9:
#				print("new_behaviour: CANT_REACH_PLAYER")
		
		
		
		# Reset timer
		ideling_time = 0.0
		searching_time = 0.0
		pre_attack_time = 0.0
		
		# Reset variables
		is_directly_attacking = false
		
		# Handle new bahaviour
		match new_behaviour:
			
			SLEEPING:
				behaviour_state = SLEEPING
				mob_need_path = false
				
				# Start regeneration of hp
				should_regenerate_hp(true)
			
			
			IDLING:
				# Set new max_ideling_time for IDLING
				rng.randomize()
				max_ideling_time = rng.randi_range(3, 10)
				
#				print("IDLING")
				behaviour_state = IDLING
				mob_need_path = false
				change_animations(IDLING)
				
				# Start regeneration of hp
				should_regenerate_hp(true)
			
			
			WANDERING:
				speed = WANDERING_SPEED
				
				if behaviour_state != WANDERING:
					# Reset path in case player is seen but e.g. state is wandering
					path.resize(0)
					
					if Constants.SHOW_BOSS_PATHES:
						# Update line path
						line2D.points = []
				
#				print("WANDERING")
				behaviour_state = WANDERING
				mob_need_path = true
				change_animations(WANDERING)
				
				# Start regeneration of hp
				should_regenerate_hp(true)
			
			
			HUNTING:
				speed = HUNTING_SPEED
				
				if behaviour_state != HUNTING:
					# Reset path in case player is seen but e.g. state is wandering
					path.resize(0)
					
					if Constants.SHOW_BOSS_PATHES:
						# Update line path
						line2D.points = []
#				print("HUNTING")
				behaviour_state = HUNTING
				mob_need_path = true
				change_animations(HUNTING)
				
				# Stop regeneration of hp
				should_regenerate_hp(false)
			
			
			SEARCHING:
				# Set variables
				speed = WANDERING_SPEED
				
				# start_searching_position -> last eye contact to player
				if path.size() > 0:
					start_searching_position = path[-1]
				else:
					start_searching_position = global_position
					
				# Set new current_max_searching_time for SEARCHING
				rng.randomize()
				current_max_searching_time = rng.randi_range(min_searching_time, max_searching_time)
				
#				print("SEARCHING")
				behaviour_state = SEARCHING
				mob_need_path = false
				change_animations(SEARCHING)
				
				# Start regeneration of hp
				should_regenerate_hp(true)
			
			
			HURTING:
#				print("HURTING")
				if behaviour_state != HURTING:
					behaviour_state = HURTING
					# Show hurt animation if not already played
					change_animations(HURTING)
					
					# Stop regeneration of hp
					should_regenerate_hp(false)
			
			
			DYING:
#				print("DYING")
				if behaviour_state != DYING:
					behaviour_state = DYING
					# Show hurt animation if not already played
					change_animations(DYING)
					
					# Start regeneration of hp
					should_regenerate_hp(false)
			
			
			PRE_ATTACKING:
				speed = PRE_ATTACKING_SPEED
				
				if behaviour_state != PRE_ATTACKING:
					# Reset path in case player is seen but e.g. state is wandering
					path.resize(0)
					
					if Constants.SHOW_BOSS_PATHES:
						# Update line path
						line2D.points = []
						
#				print("PRE_ATTACKING")
				behaviour_state = PRE_ATTACKING
				mob_need_path = true
				change_animations(PRE_ATTACKING)
				
				# Disable damagaAreaShape - If the player is too close to the mob, it will not be recognised as new
				damageAreaShape.set_deferred("disabled", true)
				
				# Get attack style - Directly or Area
				randomize()
				var probability = rand_range(0.0, 1.0)
				if probability <= DIRECT_ATTACK_STYLE_PROBABILITY:
					is_directly_attacking = true
				pre_attack_time = 0.0
				max_pre_attack_time = get_new_pre_attack_time(boss_type)
			
			
			ATTACKING:
				if behaviour_state != ATTACKING:
					# Reset path in case player is seen but e.g. state is wandering
					path.resize(0)
					
					if Constants.SHOW_BOSS_PATHES:
						# Update line path
						line2D.points = []
				
				# Move Mob to player and further more
				update_animations()
#				print("ATTACKING")
				behaviour_state = ATTACKING
				mob_need_path = false
				change_animations(ATTACKING)
				
				# Enable damagaAreaShape - If the player is too close to the mob, it will not be recognised as new
				damageAreaShape.set_deferred("disabled", false)
			
			
			CANT_REACH_PLAYER:
				speed = WANDERING_SPEED
				
				if behaviour_state != CANT_REACH_PLAYER:
					# Reset path in case player is seen but e.g. state is wandering
					path.resize(0)
					
					if Constants.SHOW_BOSS_PATHES:
						# Update line path
						line2D.points = []
				
#				print("CANT_REACH_PLAYER")
				behaviour_state = CANT_REACH_PLAYER
				mob_need_path = true
				
				# Inform pathfinder to check if mob can reach player
				check_can_reach_player = true
				
				change_animations(WANDERING)
				
				# Start regeneration of hp
				should_regenerate_hp(true)
	
	return updated


# Method to update the animation with velocity for direction -> needs to code in child
func update_animations():
	pass


# Method to change the animations dependent on behaviour state -> needs to code in child
func change_animations(_animation_behaviour_state):
	pass


# Method to update the view direction with custom value
func set_view_direction(_view_direction):
	pass


# Method returns next target position to pathfinding_service
func get_target_position():
	update_get_target_position = true


# Method is called from pathfinding_service to set new path to mob
func update_path(new_path):
	# Update mob path if it still need it
	if mob_need_path:
		path = new_path
		mob_need_path = false
		
		if path.size() <= 1 and behaviour_state == HUNTING and global_position.distance_to(Utils.get_current_player().global_position) >= CANT_REACH_DISTANCE:
			update_behaviour(CANT_REACH_PLAYER)
		
		if Constants.SHOW_BOSS_PATHES:
			# Update line path
			line2D.points = path


# Method is called from chunk_loader_service to set mob activity
func set_mob_activity(is_active):
	if not is_active and behaviour_state != SLEEPING:
		# Set mob to be sleeping
		update_behaviour(SLEEPING)
	elif is_active and behaviour_state == SLEEPING:
		# wake up the mob to what it has done before
		update_behaviour(previous_behaviour_state)


# Method to simulate damage and behaviour to mob
func simulate_damage(damage_to_mob : int, knockback_to_mob : int):
	if behaviour_state != DYING:
		# Add damage
		health -= damage_to_mob
		
		# Update healthbar in boss
		if not is_in_boss_room:
			var healthbar_value_in_percent = (100.0 / max_health) * health
			healthBar.value = healthbar_value_in_percent
			if not healthBarNode.visible:
				healthBarNode.visible = true
		# Update healthbar in player ui
		elif is_in_boss_room:
			var healthbar_value_in_percent = (100.0 / max_health) * health
			Utils.get_player_ui().set_boss_health(healthbar_value_in_percent)
		
		# Mob is killed
		if health <= 0:
			sound.stream = Constants.PreloadedSounds.Win
			sound.play(0.03)
            if Utils.get_player_ui().get_current_quest() == "QUEST2" and !Utils.get_player_ui().is_quest_finished():
			    Utils.get_player_ui().set_quest_finished(true)
		    elif (Utils.get_player_ui().get_current_quest() == "QUEST1" and !Utils.get_player_ui().is_quest_finished() 
			    and "Dungeon" in  Utils.get_scene_manager().current_transition_data.get_scene_path()):
			    Utils.get_player_ui().set_quest_finished(true)
		    elif Utils.get_player_ui().get_current_quest() == "QUEST3" and !Utils.get_player_ui().is_quest_finished():
                Utils.get_player_ui().set_quest_progress(1)
			update_behaviour(DYING)
		else:
			update_behaviour(HURTING)
			
		# Add knockback
		# Caluculate linear function between min_knockback_velocity_factor and max_knockback_velocity_factor to get knockback_velocity_factor depending on knockback between min_knockback_velocity_factor and max_knockback_velocity_factor
		var min_knockback_velocity_factor = Constants.BossesSettings.GENERAL.MinKnockbackVelocityFactorToBoss
		var max_knockback_velocity_factor = Constants.BossesSettings.GENERAL.MaxKnockbackVelocityFactorToBoss
		var m = (max_knockback_velocity_factor - min_knockback_velocity_factor) / Constants.MAX_KNOCKBACK
		var knockback_velocity_factor = m * knockback_to_mob + min_knockback_velocity_factor - mob_weight
		velocity = Utils.get_current_player().global_position.direction_to(global_position) * knockback_velocity_factor


# Method is called when HURT animation is done
func mob_hurt():
	if previous_behaviour_state != HURTING: # Because sometimes animations are stuck
		update_behaviour(previous_behaviour_state)


# Method is called when DIE animation is done
func mob_killed():
	if not killed:
		killed = true
		# Spawn way to first lvl in dungeon if boss is killed in dungeon's boss room
		if is_in_boss_room:
			Utils.get_scene_manager().get_current_scene().spawn_key_at_death(global_position)
		
		Utils.get_player_ui().show_boss_health_bar(false)
		Utils.get_current_player().set_exp(Utils.get_current_player().get_exp() + experience)
		Utils.get_scene_manager().get_current_scene().despawn_boss(self)


# Method to return a random pre_attack_time of specifiy current_boss_type
func get_new_pre_attack_time(current_boss_type) -> float:
	# Don't wait
	if is_directly_attacking:
		return 0.0
	
	# Wait some time depending on current_boss_type
	else:
		match current_boss_type:
			BossType.BOSS_FUNGUS:
				return rng.randf_range(1.0, 3.0)
				
			BossType.BOSS_GHOST:
				return rng.randf_range(0.0, 2.5)
				
			BossType.BOSS_ORBINAUT:
				return rng.randf_range(0.0, 2.5)
				
			BossType.BOSS_SKELETON:
				return rng.randf_range(1.0, 3.0)
				
			BossType.BOSS_SMALL_SLIME:
				return rng.randf_range(0.0, 2.5)
				
			BossType.BOSS_ZOMBIE:
				return rng.randf_range(1.0, 3.0)
		
		# Default
		print("-----------------> DEFAULT: " + str(current_boss_type))
		return rng.randf_range(0.0, 1.0)


# Method to return the attack_damage
func get_attack_damage(mob_attack_damage):
	randomize()
	var random_float = randf()
	
	# Calculate damage
	if random_float <= Constants.AttackDamageStatesProbabilityWeights[Constants.AttackDamageStates.CRITICAL_ATTACK]:
		# Return CRITICAL_ATTACK damage
		var damage = mob_attack_damage * Constants.CRITICAL_ATTACK_DAMAGE_FACTOR
		return damage
	
	else:
		# Return NORMAL_ATTACK damage
		rng.randomize()
		var normal_attack_factor = rng.randf_range(Constants.NORMAL_ATTACK_MIN_DAMAGE_FACTOR, Constants.NORMAL_ATTACK_MAX_DAMAGE_FACTOR)
		var damage = int(round(mob_attack_damage * normal_attack_factor))
		return damage


# Method to set if boss is in grassland or not
func is_boss_in_grassland(new_in_grassland):
	in_grassland = new_in_grassland


# Method to enable or disable hp regeneration
func should_regenerate_hp(should_regenerate):
	# Start regenerate hp
	if should_regenerate and health < max_health:
		regenerate_hp = true
	# Stop regenerate hp
	else:
		regenerate_hp = false


# Method to generate hp with delta time
func regenerate_hp_bar(delta):
	regeneration_interval += delta
	if regeneration_interval > max_regeneration_interval:
		regeneration_interval = 0.0
		
		# Update health
		if health < max_health:
			health = health + REGENERATION_HP_AMOUNT
		if health > max_health:
			health = max_health
		
		# Update healthbar in boss
		if not is_in_boss_room:
			var healthbar_value_in_percent = (100.0 / max_health) * health
			healthBar.value = healthbar_value_in_percent
			if not healthBarNode.visible and health < max_health:
				# Enable healthbar visibility if getting damage
				healthBarNode.visible = true
			elif healthBarNode.visible and health == max_health:
				# Disable healthbar visibility if full hp
				healthBarNode.visible = false
		# Update healthbar in player ui
		elif is_in_boss_room:
			var healthbar_value_in_percent = (100.0 / max_health) * health
			Utils.get_player_ui().set_boss_health(healthbar_value_in_percent)


# Method to check if boss can attack player
func can_attack():
	# Check if boss can see player
	if not Utils.get_current_player().is_player_invisible():
		# Check distance to player
		if global_position.distance_to(Utils.get_current_player().global_position) <= (attack_radius * 1.3):
			raycast.cast_to = Utils.get_current_player().global_position - global_position
			raycast.force_raycast_update()
			# Check if there is a collision between player and boss
			if not raycast.is_colliding():
				return true
	else:
		return false


# Pathfinder notifys to boss if it can reach the player in case CANT_REACH_PLAYER
func can_reach_player(can_reach, reachable_path):
	if can_reach:
		if reachable_path.size() > 0:
			# Check if final point is in reachable near of player
			var end_position : Vector2 = reachable_path[-1]
			if end_position.distance_to(Utils.get_current_player().global_position) >= CANT_REACH_DISTANCE:
				return
		
		check_can_reach_player = false
		update_behaviour(HUNTING)

