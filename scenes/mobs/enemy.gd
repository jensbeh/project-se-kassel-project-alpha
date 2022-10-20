extends KinematicBody2D

# Constants
var HUNTING_SPEED = 100
var WANDERING_SPEED = 50
var PRE_ATTACKING_SPEED

# Mob specific
var max_health = 100
var health = 100
var attack_damage = 15
var knockback = 0
var spawn_time = Constants.SpawnTime.ALWAYS
var mob_weight
var experience = 10

# Variables
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
}
var velocity = Vector2(0, 0)
var behaviour_state = IDLING
var previous_behaviour_state = IDLING
var collision_radius
var spawnArea
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
var scene_type
var killed = false
var update_get_target_position = false
var new_position_dic : Dictionary = {}

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
var min_searching_time = 6
var max_searching_time = 12

# Nodes
onready var collision = $Collision
onready var playerDetectionZone = $PlayerDetectionZone
onready var playerDetectionZoneShape = $PlayerDetectionZone/DetectionShape
onready var playerAttackZone = $PlayerAttackZone
onready var playerAttackZoneShape = $PlayerAttackZone/AttackShape
onready var damageAreaShape = $DamageArea/CollisionShape2D
onready var line2D = $Line2D
onready var healthBar = $NinePatchRect/ProgressBar
onready var healthBarBackground = $NinePatchRect
onready var raycast = $RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Show or hide line node for debugging
	line2D.visible = Constants.SHOW_MOB_PATHES
	
	# Set spawn_position
	collision_radius = collision.shape.radius
	var spawn_position : Vector2 = Utils.generate_position_in_mob_area(scene_type, spawnArea, navigation_tile_map, collision_radius, true)
	position = spawn_position
#	position = Vector2(100, 100)
	
	# Set init max_ideling_time for startstate IDLING
	rng.randomize()
	max_ideling_time = rng.randi_range(0, 8)
	
	# Setup initial mob view direction
	velocity = Vector2(rng.randi_range(-1,1), rng.randi_range(-1,1))
	
	# Setup searching variables
	max_searching_radius = playerDetectionZoneShape.shape.radius
	min_searching_radius = max_searching_radius * 0.33
	
	playerAttackZone.connect("player_entered_attack_zone", self, "on_player_entered_attack_zone")
	playerAttackZone.connect("player_exited_attack_zone", self, "on_player_exited_attack_zone")
	
	# Healthbar
	healthBar.value = 100
	healthBar.visible = false
	healthBarBackground.visible = false
	
	# Setup attacking radius around player variables
	max_attacking_radius_around_player = playerAttackZoneShape.shape.radius * 0.95
	min_attacking_radius_around_player = playerAttackZoneShape.shape.radius * 0.85
	
	# Update mobs activity depending on is in active chunk or not
	ChunkLoaderService.update_mob(self)
	
	
	
	raycast.enabled = true



# Method to init variables, typically called after instancing
func init(init_spawnArea, new_navigation_tile_map, init_scene_type):
	spawnArea = init_spawnArea
	navigation_tile_map = new_navigation_tile_map
	scene_type = init_scene_type


func _physics_process(delta):
#	if update_get_target_position:
		# Handle behaviour
#		match behaviour_state:
#			# Return player hunting position if player is still existing
#			HUNTING:
##				print("HUNTING")
##				print("HERE1")
#				var player = playerDetectionZone.player
#				if player != null:
#					PathfindingService.call_deferred("got_position", self, playerDetectionZone.player.global_position)
#					update_get_target_position = false
#					print("HERE2")
#					print("")
#					print("")
			
			
			# Return next wandering position
#			WANDERING:
##				print("WANDERING")
#				var new_position = Vector2.ZERO
#				new_position = Utils.generate_position_in_mob_area(scene_type, spawnArea, navigation_tile_map, collision_radius, false)
#				PathfindingService.call_deferred("got_position", self, new_position)
#				update_get_target_position = false
#
#
#			SEARCHING:
##				print("SEARCHING")
#				if not new_position_dic.empty() and not new_position_dic["generate_again"]:
#					raycast.cast_to = new_position_dic["position"] - global_position
#					raycast.force_raycast_update()
#
#					if not raycast.is_colliding():
#						PathfindingService.call_deferred("got_position", self, new_position_dic["position"])
#						update_get_target_position = false
#					else:
#						printerr("SEARCHING: GENERATE POSITION AGAIN -> RAYCAST.IS_COLLIDING == TRUE")
#					new_position_dic.clear()
#
#
#			PRE_ATTACKING:
##				print("PRE_ATTACKING")
#				if not new_position_dic.empty() and not new_position_dic["generate_again"]:
#					raycast.cast_to = new_position_dic["position"] - global_position
#					raycast.force_raycast_update()
#
#					if not raycast.is_colliding():
#						PathfindingService.call_deferred("got_position", self, new_position_dic["position"])
#						update_get_target_position = false
#					else:
#						printerr("PRE_ATTACKING: GENERATE POSITION AGAIN -> RAYCAST.IS_COLLIDING == TRUE")
#					new_position_dic.clear()
	
	
	# Handle behaviour
	match behaviour_state:
		
		IDLING:
			# Mob is doing nothing, just standing and searching for player
			velocity = velocity.move_toward(Vector2(0, 0), friction * delta)
		
		
		WANDERING:
			if not mob_need_path:
				# Mob is wandering around and is searching for player
				# Follow wandering path
				if path.size() > 0:
					move_to_position(delta)
		
		
		HUNTING:
			# Check if player is nearby
			var player = playerDetectionZone.player
			if player != null:
				# Follow path
				if path.size() > 0:
					move_to_position(delta)
		
		
		SEARCHING:
			if not mob_need_path:
				# Mob is wandering around and is searching for player
				# Follow searching path
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


func _process(delta):
#	if update_get_target_position:
		# Handle behaviour
#		match behaviour_state:
#			SEARCHING:
##				print("SEARCHING")
#				if new_position_dic.empty() or new_position_dic["generate_again"]:
#					new_position_dic = Utils.generate_position_near_mob(scene_type, start_searching_position, min_searching_radius, max_searching_radius, navigation_tile_map, collision_radius)
#					printerr("SEARCHING: GENERATED POSITION")
#
#			PRE_ATTACKING:
##				print("PRE_ATTACKING")
#				if new_position_dic.empty() or new_position_dic["generate_again"]:
#					new_position_dic = Utils.generate_position_near_mob(scene_type, Utils.get_current_player().global_position, min_attacking_radius_around_player, max_attacking_radius_around_player, navigation_tile_map, collision_radius)
#					printerr("PRE_ATTACKING: GENERATED POSITION")
	
	
	
	# Handle behaviour
	match behaviour_state:
		IDLING:
			search_player()
			
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
				
			# Check if player is nearby (needs to be at the end of WANDERING)
			search_player()
		
		
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
			
			
			# Mob is doing nothing, just standing and searching for player
			search_player()


# Method to move the mob to position
func move_to_position(delta):
	# Stop motion when reached position
#	print("A")
	if global_position.distance_to(path[0]) < position_threshold:
		path.remove(0)
#		print("D")
		if Constants.SHOW_MOB_PATHES:
			# Update line
			line2D.points = path
	else:
#		print("E")
		# Move mob
		var direction = global_position.direction_to(path[0])
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		velocity = move_and_slide(velocity)
#		print("F")
		# Update anmination
		update_animations()
		
		if Constants.SHOW_MOB_PATHES:
			# Update line position
			line2D.global_position = Vector2(0,0)
#		print("G")
#	print("B")
	
	if Constants.SHOW_MOB_PATHES:
		if path.size() == 0:
			line2D.points = []
	
#	print("C")
#	print("")
#	print("")

# Method to search for player
func search_player():
	if playerDetectionZone.mob_can_see_player():
		# Player in detection zone of this mob
		update_behaviour(HUNTING)


# Method to update the behaviour of the mob
func update_behaviour(new_behaviour):
	if behaviour_state != new_behaviour:
		
		# Set previous behaviour state
		previous_behaviour_state = behaviour_state
		
		# Reset timer
		ideling_time = 0.0
		searching_time = 0.0
		pre_attack_time = 0.0
		
		# Handle new bahaviour
		match new_behaviour:
			
			SLEEPING:
				behaviour_state = SLEEPING
				mob_need_path = false
			
			
			IDLING:
				# Set new max_ideling_time for IDLING
				rng.randomize()
				max_ideling_time = rng.randi_range(3, 10)
				
#				print("IDLING")
				behaviour_state = IDLING
				mob_need_path = false
				change_animations(IDLING)
			
			
			WANDERING:
				speed = WANDERING_SPEED
				
				if behaviour_state != WANDERING:
					# Reset path in case player is seen but e.g. state is wandering
					path.resize(0)
					
					if Constants.SHOW_MOB_PATHES:
						# Update line path
						line2D.points = []
				
#				print("WANDERING")
				behaviour_state = WANDERING
				mob_need_path = true
				change_animations(WANDERING)
			
			
			HUNTING:
				speed = HUNTING_SPEED
				
				if behaviour_state != HUNTING:
					# Reset path in case player is seen but e.g. state is hunting
					path.resize(0)
					
					if Constants.SHOW_MOB_PATHES:
						# Update line path
						line2D.points = []
#				print("HUNTING")
				behaviour_state = HUNTING
				mob_need_path = true
				change_animations(HUNTING)
			
			
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
			
			
			HURTING:
#				print("HURTING")
				if behaviour_state != HURTING:
					behaviour_state = HURTING
					# Show hurt animation if not already played
					change_animations(HURTING)
			
			
			DYING:
#				print("DYING")
				if behaviour_state != DYING:
					behaviour_state = DYING
					# Show hurt animation if not already played
					change_animations(DYING)


# Method to update the animation with velocity for direction -> needs to code in child
func update_animations():
	pass


# Method to change the animations dependent on behaviour state -> needs to code in child
func change_animations(_animation_behaviour_state):
	pass


# Method returns next target position to pathfinding_service
func get_target_position():
#	print("get_target_position")
#	print(behaviour_state)
#	call_deferred("update_position")
#	update_get_target_position = true
	PathfindingService.call_deferred("got_position", self, Utils.get_current_player().global_position)


#func update_position():

## Method returns next target position to pathfinding_service
#func get_target_position():
#	# Return player hunting position if player is still existing
#	if behaviour_state == HUNTING:
#		var player = playerDetectionZone.player
#		if player != null:
#			return playerDetectionZone.player.global_position
#		else:
#			return null
#
#
#	# Return next wandering position
#	elif behaviour_state == WANDERING:
#		return Utils.generate_position_in_mob_area(scene_type, spawnArea, navigation_tile_map, collision_radius, false)
#
#
#	# Return next searching position
#	elif behaviour_state == SEARCHING:
#		var generate_position = true
#		var position = Vector2.ZERO
#
#		while (generate_position):
#			position = Utils.generate_position_near_mob(scene_type, start_searching_position, min_searching_radius, max_searching_radius, navigation_tile_map, collision_radius)
#
#			raycast.cast_to = position - global_position
##			raycast.force_raycast_update()
#
#			if not raycast.is_colliding():
#				generate_position = false
#
#			else:
#				printerr("SEARCHING: GENERATE POSITION AGAIN -> RAYCAST.IS_COLLIDING == TRUE")
#
#		return position
#
#
#	elif behaviour_state == PRE_ATTACKING:
#		var generate_position = true
#		var position = Vector2.ZERO
#
#		while (generate_position):
#			position = Utils.generate_position_near_mob(scene_type, Utils.get_current_player().global_position, min_attacking_radius_around_player, max_attacking_radius_around_player, navigation_tile_map, collision_radius)
#
#			raycast.cast_to = position - global_position
#			raycast.call_deferred("force_raycast_update")
#
#			if not raycast.is_colliding():
#				generate_position = false
#
#			else:
#				printerr("PRE_ATTACKING: GENERATE POSITION AGAIN -> RAYCAST.IS_COLLIDING == TRUE")
#
#		return position


# Method is called from pathfinding_service to set new path to mob
func update_path(new_path):
	# Update mob path if it still need it
	if mob_need_path:
		path = new_path
		mob_need_path = false
		
		if Constants.SHOW_MOB_PATHES:
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


func on_player_entered_attack_zone():
	if behaviour_state != DYING and behaviour_state != HURTING: # Because if mob is dying/hurting then state should be change with area's
		update_behaviour(PRE_ATTACKING)


func on_player_exited_attack_zone():
	if behaviour_state != DYING and behaviour_state != HURTING: # Because if mob is dying/hurting then state should be change with area's
		update_behaviour(HUNTING)


# Method to simulate damage and behaviour to mob
func simulate_damage(damage_to_mob : int, knockback_to_mob : int):
	# Add damage
	health -= damage_to_mob
	
	# Healthbar
	var healthbar_value_in_percent = (100.0 / max_health) * health
	healthBar.value = healthbar_value_in_percent
	if not healthBar.visible:
		healthBar.visible = true
		healthBarBackground.visible = true
	
	# Mob is killed
	if health <= 0:
		update_behaviour(DYING)
	else:
		update_behaviour(HURTING)
		
	# Add knockback
	# Caluculate linear function between min_knockback_velocity_factor and max_knockback_velocity_factor to get knockback_velocity_factor depending on knockback between min_knockback_velocity_factor and max_knockback_velocity_factor
	var min_knockback_velocity_factor = 50
	var max_knockback_velocity_factor = 200
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
		Utils.get_current_player().set_exp(Utils.get_current_player().get_exp() + experience)
		MobSpawnerService.despawn_mob(self)


# Method to return a random time between min_time and max_time
func get_new_pre_attack_time(min_time, max_time) -> float:
	return rng.randf_range(min_time, max_time)


# Method to return the attack_damage
func get_attack_damage(mob_attack_damage):
	randomize()
	var random_float = randf()
	
	# Calculate damage
	if random_float <= Constants.AttackDamageStatesWeights[Constants.AttackDamageStates.CRITICAL_ATTACK]:
		# Return CRITICAL_ATTACK damage
		var damage = mob_attack_damage * Constants.CRITICAL_ATTACK_DAMAGE_FACTOR
		return damage
	
	else:
		# Return NORMAL_ATTACK damage
		rng.randomize()
		var normal_attack_factor = rng.randf_range(Constants.NORMAL_ATTACK_MIN_DAMAGE_FACTOR, Constants.NORMAL_ATTACK_MAX_DAMAGE_FACTOR)
		var damage = int(round(mob_attack_damage * normal_attack_factor))
		return damage
