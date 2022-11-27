extends KinematicBody2D

# Signals
signal player_collided(collision)
signal player_looting
signal player_interact
signal current_health_updated
signal current_stamina_updated

# Animation
onready var animation_tree = $AnimationTree
onready var animation_player = $AnimationPlayer
onready var animation_state = animation_tree.get("parameters/playback")

# Look
onready var shadow = $Shadow
onready var bodySprite = $Body
onready var shoesSprite = $Shoes
onready var pantsSprite = $Pants
onready var clothesSprite = $Clothes
onready var blushSprite = $Blush
onready var lipstickSprite = $Lipstick
onready var beardSprite = $Beard
onready var eyesSprite = $Eyes
onready var earringSprite = $Earring
onready var hairSprite = $Hair
onready var maskSprite = $Mask
onready var glassesSprite = $Glasses
onready var hatSprite = $Hat
onready var weaponSprite = $Weapon
onready var attackSwingSprite = $AttackSwing
onready var sound_walk = $SoundWalk
onready var sound = $Sound
onready var sound_breath = $SoundBreath

# Count Textures, Count Colors
var curr_body: int = 0 #0-7, 1
var curr_shoes: int = 0 #0, 10
var curr_pants: int = 0 #0-2, 10
var curr_clothes: int = 0 #0-10, 10 -> not by everyone
var curr_blush: int = 0 #0, 5
var curr_lipstick: int = 0 #0, 5
var curr_beard: int = 0 #0, 14
var curr_eyes: int = 0 #0, 14
var curr_earring: int = 0 #0-3, 1
var curr_hair: int = 0 #0-13, 14
var curr_mask: int = 0 #0-2, 1
var curr_glasses: int = 0 #0-1, 10
var curr_hat: int = 0 #0-4, 1

# Walk
var current_walk_speed = Constants.PLAYER_WALK_SPEED
var velocity = Vector2(0,1)
var view_direction = Vector2(0,1)
var movement

# Interaction
var player_can_interact = true

# player stats and values
var gold: int
var attack_damage: int = 0
var knockback: int = 0
var attack_speed: int = 0
var max_health: int
var current_health: int
var data
var level: int = 1
var player_exp: int = 0
var max_stamina: float
var player_stamina: float
var player_light_radius: int
var health_cooldown = 0
var stamina_cooldown = 0
var weapon_weight = 0
var stairs_speed = false
var preview = false

# Variables
var is_attacking = false
var can_attack = false
var hurting = false
var dying = false
var is_invincible = false
var collecting = false
var collected = false
var in_safe_area = false
var in_change_scene_area = false
var is_player_paused = false


func _ready():
	# Style
	bodySprite.texture = Constants.PreloadedPlayerSprites.BODY_SPRITESHEET[curr_body]
	shoesSprite.texture = Constants.PreloadedPlayerSprites.SHOES_SPRITESHEET[curr_shoes]
	pantsSprite.texture = Constants.PreloadedPlayerSprites.PANTS_SPRITESHEET[curr_pants]
	clothesSprite.texture = Constants.PreloadedPlayerSprites.CLOTHES_SPRITESHEET[curr_clothes]
	blushSprite.texture = Constants.PreloadedPlayerSprites.BLUSH_SPRITESHEET[curr_blush]
	lipstickSprite.texture = Constants.PreloadedPlayerSprites.LIPSTICK_SPRITESHEET[curr_lipstick]
	beardSprite.texture = Constants.PreloadedPlayerSprites.BEARD_SPRITESHEET[curr_beard]
	eyesSprite.texture = Constants.PreloadedPlayerSprites.EYES_SPRITESHEET[curr_eyes]
	earringSprite.texture = Constants.PreloadedPlayerSprites.EARRING_SPRITESHEET[curr_earring]
	hairSprite.texture = Constants.PreloadedPlayerSprites.HAIR_SPRITESHEET[curr_hair]
	maskSprite.texture = Constants.PreloadedPlayerSprites.MASK_SPRITESHEET[curr_mask]
	glassesSprite.texture = Constants.PreloadedPlayerSprites.GLASSES_SPRITESHEET[curr_glasses]
	hatSprite.texture = Constants.PreloadedPlayerSprites.HAT_SPRITESHEET[curr_hat]
	
	shadow.visible = false
	
	# Sets the Visibility of a given Sprite
	set_visibility("Mask", false) #Sprite, true/false
	set_visibility("Glasses", false)
	set_visibility("Earrings", false)
	set_visibility("Hat", false)
	set_visibility("Weapon", false)
	set_visibility("AttackSwing", false)
	
	# Animation
	animation_tree.active = true
	animation_tree.set("parameters/Idle/blend_position", velocity)
	animation_tree.set("parameters/Walk/blend_position", velocity)
	animation_tree.set("parameters/Hurt/blend_position", velocity)
	animation_tree.set("parameters/Collect/blend_position", velocity)
	animation_tree.set("parameters/Collected/blend_position", velocity)
	animation_tree.set("parameters/Attack/AttackCases/blend_position", velocity)
	
	
	# For debugging
	# Invisibility
	if Constants.IS_PLAYER_INVISIBLE:
		make_player_invisible(Constants.IS_PLAYER_INVISIBLE)
	else:
		make_player_invisible(Constants.IS_PLAYER_INVISIBLE)
	
	# Invincibility
	if Constants.IS_PLAYER_INVINCIBLE:
		make_player_invincible(Constants.IS_PLAYER_INVINCIBLE)
	else:
		make_player_invincible(Constants.IS_PLAYER_INVINCIBLE)


func _physics_process(delta):
	if not is_player_paused:
		if not is_attacking and not hurting and not dying and not collecting: # Disable walking if attacking
			# Handle User Input
			if Input.is_action_pressed("d") or Input.is_action_pressed("a"):
				velocity.x = (int(Input.is_action_pressed("d")) - int(Input.is_action_pressed("a"))) * current_walk_speed
			else:
				velocity.x = 0
				
			if Input.is_action_pressed("s") or Input.is_action_pressed("w"):
				velocity.y = (int(Input.is_action_pressed("s")) - int(Input.is_action_pressed("w"))) * current_walk_speed
			else:
				velocity.y = 0
			
			if (Input.is_action_pressed("s") or Input.is_action_pressed("w")) and (Input.is_action_pressed("d") or Input.is_action_pressed("a")):
				velocity /= 1.45
				
			if Input.is_action_pressed("Shift") and velocity != Vector2.ZERO and !preview and movement:
				if player_stamina - delta * Constants.STAMINA_SPRINT >= 0:
					if not Constants.HAS_PLAYER_INFINIT_STAMINA:
						set_current_stamina(player_stamina - delta * Constants.STAMINA_SPRINT)
					step_sound(1.2)
					velocity *= 1.4
				else:
					step_sound(1)
			else:
				step_sound(1)
			
			if velocity != Vector2.ZERO and player_can_interact:
				view_direction = velocity
				animation_tree.set("parameters/Idle/blend_position", velocity)
				animation_tree.set("parameters/Walk/blend_position", velocity)
				animation_tree.set("parameters/Hurt/blend_position", velocity)
				animation_tree.set("parameters/Collect/blend_position", velocity)
				animation_tree.set("parameters/Collected/blend_position", velocity)
				animation_tree.set("parameters/Attack/AttackCases/blend_position", velocity)
				animation_state.travel("Walk")
			else:
				animation_state.travel("Idle")
			
			if movement:
				if !sound_walk.is_playing() and velocity != Vector2.ZERO and !preview:
					sound_walk.play()
				elif velocity == Vector2.ZERO and sound_walk.is_playing() or preview:
					sound_walk.stop()
				velocity = move_and_slide(velocity)
				for i in get_slide_count():
					var collision = get_slide_collision(i)
					if collision != null and !collision.get_collider().get_parent().get_meta_list().empty():
						emit_signal("player_collided", collision.get_collider())
			else:
				sound_walk.stop()
		
		elif (hurting or dying) and velocity != Vector2.ZERO and not collecting:
			# handle knockback when hurting or dying
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			velocity = move_and_slide(velocity)
			
		if not is_attacking and not hurting and not dying and data != null and not (Input.is_action_pressed("Shift") and velocity != Vector2.ZERO):
			if player_stamina + delta * Constants.STAMINA_RECOVER < get_max_stamina():
				set_current_stamina(player_stamina + delta * Constants.STAMINA_RECOVER)
			elif player_stamina < get_max_stamina():
				set_current_stamina(get_max_stamina())
		# Breath Sound
		if weapon_weight < 0 or weapon_weight == null:
			weapon_weight = 1
		if ((player_stamina - delta * Constants.STAMINA_SPRINT < 0 or player_stamina - weapon_weight * Constants.WEAPON_STAMINA_USE < 0) 
		and !Utils.get_scene_manager().get_current_scene_type() == Constants.SceneType.MENU):
			if !sound_breath.is_playing():
				sound_breath.play()
		elif sound_breath.is_playing():
			sound_breath.stop()
	if is_player_paused and sound_breath.is_playing():
		sound_breath.stop()


# Method to set right step sound
func step_sound(value):
	if "Grassland" in Utils.get_scene_manager().get_current_scene().name:
		if sound_walk.stream != Constants.PreloadedSounds.Steps_Grassland:
			sound_walk.stream = Constants.PreloadedSounds.Steps_Grassland
	elif "Dungeon" in Utils.get_scene_manager().get_current_scene().name:
		if sound_walk.stream != Constants.PreloadedSounds.Steps_Dungeon:
			sound_walk.stream = Constants.PreloadedSounds.Steps_Dungeon
	elif "Camp" in Utils.get_scene_manager().get_current_scene().name:
		if sound_walk.stream != Constants.PreloadedSounds.Steps_Camp:
			sound_walk.stream = Constants.PreloadedSounds.Steps_Camp
	else:
		if sound_walk.stream != Constants.PreloadedSounds.Steps_House:
			sound_walk.stream = Constants.PreloadedSounds.Steps_House
	if !stairs_speed:
		sound_walk.pitch_scale = value
	else:
		sound_walk.pitch_scale = value - 0.1


# Method handles key inputs
func _input(event):
	if not is_player_paused:
		if event.is_action_pressed("e"):
			if (player_can_interact and not is_attacking and not is_player_dying()):
				emit_signal("player_interact")
			
			# Remove the Loot Panel
			elif Utils.get_loot_panel() != null:
				# Call close Method in Loot Panel
				Utils.get_loot_panel()._on_Close_pressed()
				
			# Remove the trade inventory
			elif Utils.get_trade_inventory() != null:
				Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI)
				Utils.get_trade_inventory().queue_free()
				Utils.get_current_player().set_player_can_interact(true)
				Utils.get_current_player().set_movement(true)
				Utils.get_current_player().set_movment_animation(true)
				# Reset npc interaction state
				for npc in Utils.get_scene_manager().get_current_scene().find_node("npclayer").get_children():
					npc.set_interacted(false)
				Utils.save_game(true)
				MerchantData.save_merchant_inventory()
					
		# Attack with "left_mouse"
		elif event.is_action_pressed("attack") and not is_attacking and can_attack and movement and not hurting and not dying and not collecting:
			if player_stamina > weapon_weight * Constants.WEAPON_STAMINA_USE:
				if not Constants.HAS_PLAYER_INFINIT_STAMINA:
					set_current_stamina(player_stamina - weapon_weight *  Constants.WEAPON_STAMINA_USE)
				sound.stream = Constants.PreloadedSounds.Attack
				sound.play()
				is_attacking = true
				set_movement(false)
				animation_state.start("Attack")
		
		# Loot
		elif event.is_action_pressed("loot") and Utils.get_loot_panel() == null and not dying:
			if player_can_interact and not is_attacking and not dying:
				emit_signal("player_looting")
		
		# Loot All
		elif event.is_action_pressed("loot") and Utils.get_loot_panel() != null:
			# Call Loot all Method in Loot Panel
			Utils.get_loot_panel()._on_LootAll_pressed()


# Pause & resume player
func pause_player(should_pause):
	# Pause
	if should_pause:
		print("PLAYER: Pause")
		is_player_paused = true
	# Resume
	else:
		print("PLAYER: Resume")
		is_player_paused = false


# Method is called at the end of any attack animation
func on_attack_finished():
	set_movement(true)
	is_attacking = false


# Method to activate or disable the possibility of interaction
func set_player_can_interact(value):
	player_can_interact = value


# Method to get activate or disable state of possibility of interaction
func get_player_can_interact():
	return player_can_interact


# Method to set a new player walk speed with a factor
func set_speed(factor: float):
	stairs_speed = true
	current_walk_speed *= factor


# Method to activate or deactivate the movment state
func set_movement(can_move : bool):
	movement = can_move


# Method to return the movment state
func get_movement() -> bool:
	return movement


# Method to reset the player walk speed to const
func reset_speed():
	stairs_speed = false
	current_walk_speed = Constants.PLAYER_WALK_SPEED


# Sets the Visibility of a given Sprite
func set_visibility(sprite, visibility):
	match sprite:
		"Body":
			bodySprite.visible = visibility
		"Shoes":
			shoesSprite.visible = visibility
		"Pants":
			pantsSprite.visible = visibility
		"Clothes":
			clothesSprite.visible = visibility
		"Blush":
			blushSprite.visible = visibility
		"Lipstick":
			lipstickSprite.visible = visibility
		"Beard":
			beardSprite.visible = visibility
		"Eyes":
			eyesSprite.visible = visibility
		"Hair":
			hairSprite.visible = visibility
		"Mask":
			maskSprite.visible = visibility
		"Hat":
			hatSprite.visible = visibility
		"Earrings":
			earringSprite.visible = visibility
		"Glasses":
			glassesSprite.visible = visibility
		"Shadow":
			shadow.visible = visibility
		"Weapon":
			weaponSprite.visible = visibility
		"AttackSwing":
			attackSwingSprite.visible = visibility


# Gets the Visibility of a given Sprite
func get_visibility(sprite):
	match sprite:
		"Body":
			return bodySprite.visible
		"Shoes":
			return shoesSprite.visible
		"Pants":
			return pantsSprite.visible
		"Clothes":
			return clothesSprite.visible
		"Blush":
			return blushSprite.visible
		"Lipstick":
			return lipstickSprite.visible
		"Beard":
			return beardSprite.visible
		"Eyes":
			return eyesSprite.visible
		"Hair":
			return hairSprite.visible
		"Mask":
			return maskSprite.visible
		"Hat":
			return hatSprite.visible
		"Earrings":
			return earringSprite.visible
		"Glasses":
			return glassesSprite.visible
		"Shadow":
			return shadow.visible


# Sets the current texture
func set_texture(name, value):
	match name:
		"curr_body":
			curr_body = value
			bodySprite.texture = Constants.PreloadedPlayerSprites.BODY_SPRITESHEET[curr_body]
		"curr_shoes":
			curr_shoes = value
			shoesSprite.texture = Constants.PreloadedPlayerSprites.SHOES_SPRITESHEET[curr_shoes]
		"curr_pants":
			curr_pants = value
			pantsSprite.texture = Constants.PreloadedPlayerSprites.PANTS_SPRITESHEET[curr_pants]
		"curr_clothes":
			curr_clothes = value
			clothesSprite.texture = Constants.PreloadedPlayerSprites.CLOTHES_SPRITESHEET[curr_clothes]
		"curr_blush":
			curr_blush = value
			blushSprite.texture = Constants.PreloadedPlayerSprites.BLUSH_SPRITESHEET[curr_blush]
		"curr_lipstick":
			curr_lipstick = value
			lipstickSprite.texture = Constants.PreloadedPlayerSprites.LIPSTICK_SPRITESHEET[curr_lipstick]
		"curr_beard":
			curr_beard = value
			beardSprite.texture = Constants.PreloadedPlayerSprites.BEARD_SPRITESHEET[curr_beard]
		"curr_eyes":
			curr_eyes = value
			eyesSprite.texture = Constants.PreloadedPlayerSprites.EYES_SPRITESHEET[curr_eyes]
		"curr_earring":
			curr_earring = value
			earringSprite.texture = Constants.PreloadedPlayerSprites.EARRING_SPRITESHEET[curr_earring]
		"curr_hair":
			curr_hair = value
			hairSprite.texture = Constants.PreloadedPlayerSprites.HAIR_SPRITESHEET[curr_hair]
		"curr_mask":
			curr_mask = value
			maskSprite.texture = Constants.PreloadedPlayerSprites.MASK_SPRITESHEET[curr_mask]
		"curr_glasses":
			curr_glasses = value
			glassesSprite.texture = Constants.PreloadedPlayerSprites.GLASSES_SPRITESHEET[curr_glasses]
		"curr_hat":
			curr_hat = value
			hatSprite.texture = Constants.PreloadedPlayerSprites.HAT_SPRITESHEET[curr_hat]


func reset_key(track_idx):
	var newAnimation = animation_player.get_animation("WalkDown")
	var newValue = 1 - newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1))
	
	_set_key(track_idx, newValue)


# Track Key Value change for Colors
func _set_key(track_idx, value):
	var newDown = animation_player.get_animation("WalkDown")
	set_key(newDown, track_idx, value)
	
	var newUp = animation_player.get_animation("WalkUp")
	set_key(newUp, track_idx, value)
	
	var newRight = animation_player.get_animation("WalkRight")
	set_key(newRight, track_idx, value)
	
	var newLeft = animation_player.get_animation("WalkLeft")
	set_key(newLeft, track_idx, value)
	
	animation_player.get_animation("IdleDown").track_set_key_value(track_idx,
		animation_player.get_animation("IdleDown").track_find_key(track_idx, 0.0, 1),
		animation_player.get_animation("IdleDown").track_get_key_value(track_idx,
		newDown.track_find_key(track_idx, 0.0, 1)) + value)
	animation_player.get_animation("IdleUp").track_set_key_value(track_idx,
		animation_player.get_animation("IdleUp").track_find_key(track_idx, 0.0, 1),
		animation_player.get_animation("IdleUp").track_get_key_value(track_idx,
		newUp.track_find_key(track_idx, 0.0, 1)) + value)
	animation_player.get_animation("IdleLeft").track_set_key_value(track_idx,
		animation_player.get_animation("IdleLeft").track_find_key(track_idx, 0.0, 1),
		animation_player.get_animation("IdleLeft").track_get_key_value(track_idx,
		newLeft.track_find_key(track_idx, 0.0, 1)) + value)
	animation_player.get_animation("IdleRight").track_set_key_value(track_idx,
		animation_player.get_animation("IdleRight").track_find_key(track_idx, 0.0, 1),
		animation_player.get_animation("IdleRight").track_get_key_value(track_idx,
		newRight.track_find_key(track_idx, 0.0, 1)) + value)


func set_key(newAnimation, track_idx, value):
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1),
		newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.1, 1),
		newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.1, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.2, 1),
		newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.2, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.3, 1),
		newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.3, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.4, 1),
		newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.4, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.5, 1),
		newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.5, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.6, 1),
		newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.6, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.7, 1),
		newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.7, 1)) + value)


# Method to reset animations back to first frame
func reset_attack_key(track_str):
	# Get animation for color offset
	var newAnimation = animation_player.get_animation("AttackDown")
	# Get track from animation for color offset
	var track_idx = newAnimation.find_track(track_str)
	# Calculate offset
	var current_frame = int(newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1)))
	var current_texture_hframes = get_node(track_str.substr(0, track_str.find(":"))).hframes
	var newValue = 0 - current_frame % current_texture_hframes
	# Update frame
	_set_attack_key(track_str, newValue)


# Method to change all animiations frames/colors
func _set_attack_key(track_str, value):
	var _attack_down = animation_player.get_animation("AttackDown")
	set_attack_key(_attack_down, track_str, value)
	
	var _attack_up = animation_player.get_animation("AttackUp")
	set_attack_key(_attack_up, track_str, value)
	
	var _attack_right = animation_player.get_animation("AttackRight")
	set_attack_key(_attack_right, track_str, value)
	
	var _attack_left = animation_player.get_animation("AttackLeft")
	set_attack_key(_attack_left, track_str, value)


# Method changes the frames of the animation
func set_attack_key(attack_animation, track_str, value):
	var track_idx = attack_animation.find_track(track_str)
	
	if attack_animation.track_find_key(track_idx, 0.0, 1) != -1:
		attack_animation.track_set_key_value(track_idx, attack_animation.track_find_key(track_idx, 0.0, 1),
			attack_animation.track_get_key_value(track_idx, attack_animation.track_find_key(track_idx, 0.0, 1)) + value)
	
	if attack_animation.track_find_key(track_idx, 0.2, 1) != -1:
		attack_animation.track_set_key_value(track_idx, attack_animation.track_find_key(track_idx, 0.2, 1),
			attack_animation.track_get_key_value(track_idx, attack_animation.track_find_key(track_idx, 0.2, 1)) + value)
	
	if attack_animation.track_find_key(track_idx, 0.4, 1) != -1:
		attack_animation.track_set_key_value(track_idx, attack_animation.track_find_key(track_idx, 0.4, 1),
			attack_animation.track_get_key_value(track_idx, attack_animation.track_find_key(track_idx, 0.4, 1)) + value)
	
	if attack_animation.track_find_key(track_idx, 0.8, 1) != -1:
		attack_animation.track_set_key_value(track_idx, attack_animation.track_find_key(track_idx, 0.8, 1),
			attack_animation.track_get_key_value(track_idx, attack_animation.track_find_key(track_idx, 0.8, 1)) + value)


# Method to reset animations back to first frame
func reset_hurt_key(track_str):
	# Get animation for color offset
	var newAnimation = animation_player.get_animation("HurtDown")
	# Get track from animation for color offset
	var track_idx = newAnimation.find_track(track_str)
	# Calculate offset
	var current_frame = int(newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1)))
	var current_texture_hframes = get_node(track_str.substr(0, track_str.find(":"))).hframes
	var newValue = 0 - current_frame % current_texture_hframes
	# Update frame
	_set_hurt_key(track_str, newValue)


# Method to change all animiations frames/colors
func _set_hurt_key(track_str, value):
	var _hurt_down = animation_player.get_animation("HurtDown")
	set_hurt_key(_hurt_down, track_str, value)
	
	var _hurt_up = animation_player.get_animation("HurtUp")
	set_hurt_key(_hurt_up, track_str, value)
	
	var _hurt_right = animation_player.get_animation("HurtRight")
	set_hurt_key(_hurt_right, track_str, value)
	
	var _hurt_left = animation_player.get_animation("HurtLeft")
	set_hurt_key(_hurt_left, track_str, value)


# Method changes the frames of the animation
func set_hurt_key(hurt_animation, track_str, value):
	var track_idx = hurt_animation.find_track(track_str)
	
	if hurt_animation.track_find_key(track_idx, 0.0, 1) != -1:
		hurt_animation.track_set_key_value(track_idx, hurt_animation.track_find_key(track_idx, 0.0, 1),
			hurt_animation.track_get_key_value(track_idx, hurt_animation.track_find_key(track_idx, 0.0, 1)) + value)


# Method to reset animations back to first frame
func reset_die_key(track_str):
	# Get animation for color offset
	var newAnimation = animation_player.get_animation("Die")
	# Get track from animation for color offset
	var track_idx = newAnimation.find_track(track_str)
	# Calculate offset
	var current_frame = int(newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1)))
	var current_texture_hframes = get_node(track_str.substr(0, track_str.find(":"))).hframes
	var newValue = 0 - current_frame % current_texture_hframes
	# Update frame
	_set_die_key(track_str, newValue)


# Method to change all animiations frames/colors
func _set_die_key(track_str, value):
	var _die_animation = animation_player.get_animation("Die")
	set_die_key(_die_animation, track_str, value)


# Method changes the frames of the animation
func set_die_key(die_animation, track_str, value):
	var track_idx = die_animation.find_track(track_str)
	
	if die_animation.track_find_key(track_idx, 0.0, 1) != -1:
		die_animation.track_set_key_value(track_idx, die_animation.track_find_key(track_idx, 0.0, 1),
			die_animation.track_get_key_value(track_idx, die_animation.track_find_key(track_idx, 0.0, 1)) + value)
	
	if die_animation.track_find_key(track_idx, 1.0, 1) != -1:
		die_animation.track_set_key_value(track_idx, die_animation.track_find_key(track_idx, 1.0, 1),
			die_animation.track_get_key_value(track_idx, die_animation.track_find_key(track_idx, 1.0, 1)) + value)


# Method to reset animations back to first frame
func reset_collect_key(track_str):
	# Get animation for color offset
	var newAnimation = animation_player.get_animation("CollectDown")
	# Get track from animation for color offset
	var track_idx = newAnimation.find_track(track_str)
	# Calculate offset
	var current_frame = int(newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1)))
	var current_texture_hframes = get_node(track_str.substr(0, track_str.find(":"))).hframes
	var newValue = 0 - current_frame % current_texture_hframes
	# Update frame
	_set_collect_key(track_str, newValue)


# Method to change all animiations frames/colors
func _set_collect_key(track_str, value):
	var collect_down = animation_player.get_animation("CollectDown")
	set_collect_key(collect_down, track_str, value)
	
	var collect_up = animation_player.get_animation("CollectUp")
	set_collect_key(collect_up, track_str, value)
	
	var collect_right = animation_player.get_animation("CollectRight")
	set_collect_key(collect_right, track_str, value)
	
	var collect_left = animation_player.get_animation("CollectLeft")
	set_collect_key(collect_left, track_str, value)
	
	var collected_down = animation_player.get_animation("CollectedDown")
	set_collect_key(collected_down, track_str, value)
	
	var collected_up = animation_player.get_animation("CollectedUp")
	set_collect_key(collected_up, track_str, value)
	
	var collected_right = animation_player.get_animation("CollectedRight")
	set_collect_key(collected_right, track_str, value)
	
	var collected_left = animation_player.get_animation("CollectedLeft")
	set_collect_key(collected_left, track_str, value)


# Method changes the frames of the animation
func set_collect_key(collect_animation, track_str, value):
	var track_idx = collect_animation.find_track(track_str)
	
	if collect_animation.track_find_key(track_idx, 0.0, 1) != -1:
		collect_animation.track_set_key_value(track_idx, collect_animation.track_find_key(track_idx, 0.0, 1),
			collect_animation.track_get_key_value(track_idx, collect_animation.track_find_key(track_idx, 0.0, 1)) + value)
	
	if collect_animation.track_find_key(track_idx, 0.2, 1) != -1:
		collect_animation.track_set_key_value(track_idx, collect_animation.track_find_key(track_idx, 0.2, 1),
			collect_animation.track_get_key_value(track_idx, collect_animation.track_find_key(track_idx, 0.2, 1)) + value)
	
	if collect_animation.track_find_key(track_idx, 0.4, 1) != -1:
		collect_animation.track_set_key_value(track_idx, collect_animation.track_find_key(track_idx, 0.4, 1),
			collect_animation.track_get_key_value(track_idx, collect_animation.track_find_key(track_idx, 0.4, 1)) + value)


# Method to activate or disable the player movment animation 
func set_movment_animation(state: bool):
	animation_tree.active = state


# Method to get activate or disable state of player movment animation 
func get_movment_animation():
	return animation_tree.active


# Method to set the spawn_position and view_direction of the current player
func set_spawn(spawn_position: Vector2, init_view_direction: Vector2):
	animation_tree.active = false # Otherwise player_view_direction won't change
	animation_tree.set("parameters/Idle/blend_position", init_view_direction)
	animation_tree.set("parameters/Walk/blend_position", init_view_direction)
	animation_tree.set("parameters/Hurt/blend_position", velocity)
	animation_tree.set("parameters/Collect/blend_position", velocity)
	animation_tree.set("parameters/Collected/blend_position", velocity)
	animation_tree.set("parameters/Attack/AttackCases/blend_position", init_view_direction)
	position = spawn_position
	animation_tree.active = true


# Method to setup the current player in the new scene with all information of the template player in the scene about camera, ...
func setup_player_in_new_scene(scene_player: KinematicBody2D):
	# Setup camera
	var scene_camera = scene_player.get_node("Camera2D")
	var _new_camera = get_node("Camera2D")
	
	# Set camera zoom level
	_new_camera.zoom = scene_camera.zoom
	
	# Set camera limits
	_new_camera.limit_bottom = scene_camera.limit_bottom
	_new_camera.limit_left = scene_camera.limit_left
	_new_camera.limit_right = scene_camera.limit_right
	_new_camera.limit_top = scene_camera.limit_top
	_new_camera.current = true
	scene_camera.current = false


# Method to set/save weapon and stats to player
func set_weapon(new_weapon_id, new_attack_value: int, new_attack_speed: int, new_knockback: int):
	# Set weapon
	if new_weapon_id != null:
		weapon_weight = GameData.item_data[str(new_weapon_id)]["Weight"]
		var weapon_id_str = str(new_weapon_id)
		can_attack = true
		weaponSprite.texture = Constants.PreloadedTextures[weapon_id_str]
	# Remove weapon
	else:
		weapon_weight = 0
		can_attack = false
	
	# Set new values
	attack_damage = new_attack_value
	data.attack = new_attack_value
	
	attack_speed = new_attack_speed
	data.attack_speed = new_attack_speed
	# Update attack animation speed
	animation_tree.set("parameters/Attack/TimeScale/scale", new_attack_speed)
	
	knockback = new_knockback
	data.knockback = new_knockback


# Method to return the attack_damage
func get_attack_damage():
	randomize()
	var random_float = randf()
	
	# Calculate damage
	if random_float <= Constants.AttackDamageStatesProbabilityWeights[Constants.AttackDamageStates.CRITICAL_ATTACK]:
		# Return CRITICAL_ATTACK damage
		var damage = attack_damage * Constants.CRITICAL_ATTACK_DAMAGE_FACTOR
		return damage
	
	else:
		# Return NORMAL_ATTACK damage
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var normal_attack_factor = rng.randf_range(Constants.NORMAL_ATTACK_MIN_DAMAGE_FACTOR, Constants.NORMAL_ATTACK_MAX_DAMAGE_FACTOR)
		var damage = int(round(attack_damage * normal_attack_factor))
		return damage


func get_attack_speed():
	return attack_speed


func get_knockback():
	return knockback


func get_gold():
	return gold


func set_gold(new_gold_value: int):
	gold = new_gold_value
	data.gold = new_gold_value


func get_max_health():
	return max_health


func set_max_health(new_max_health: int):
	max_health = new_max_health
	data.maxLP = new_max_health


func get_current_health():
	return current_health


func set_current_health(new_current_health: int):
	current_health = new_current_health
	if current_health > int(max_health):
		current_health = int(max_health)
	Utils.get_player_ui().set_life(new_current_health*100 / float(max_health))
	data.currentHP = new_current_health
	
	# Emit signal that current health changed
	emit_signal("current_health_updated")


func set_data(new_data):
	data = new_data


func get_data():
	return data


func set_level(new_level: int):
	level = new_level
	data.level = new_level


func get_level():
	return level


func get_exp():
	return player_exp


# set a new exp value for the player
func set_exp(new_exp: int):
	player_exp = int(new_exp)
	# for ui update
	Utils.get_player_ui().set_exp(new_exp)
	# for save
	data.exp = player_exp


# Method to set new max stamina
func set_max_stamina(new_max_stamina: int):
	max_stamina = new_max_stamina
	data.maxStamina = new_max_stamina


# Method to return max stamina
func get_max_stamina():
	return max_stamina


# Set a new current stamina value for the player
func set_current_stamina(new_stamina: float):
	if new_stamina > get_max_stamina():
		new_stamina = get_max_stamina()
	player_stamina = new_stamina
	# for ui update
	Utils.get_player_ui().set_stamina(new_stamina)
	# for save
	data.stamina = player_stamina
	
	# Emit signal that current stamina changed
	emit_signal("current_stamina_updated")


# Return current stamina value
func get_current_stamina():
	return player_stamina


func _on_DamageAreaBottom_area_entered(area):
	if area.name == "HitboxZone":
		var entity = area.owner
		
#		print("PLAYER: Mob \"" + str(entity.name) + "\" DAMAGE BOTTOM ----> " + str(area.name))
		
		if entity.has_method("simulate_damage"):
			var damage = get_attack_damage()
			entity.simulate_damage(damage, knockback)


func _on_DamageAreaLeft_area_entered(area):
	if area.name == "HitboxZone":
		var entity = area.owner
		
#		print("PLAYER: Mob \"" + str(entity.name) + "\" DAMAGE LEFT ----> " + str(area.name))
		
		if entity.has_method("simulate_damage"):
			var damage = get_attack_damage()
			entity.simulate_damage(damage, knockback)


func _on_DamageAreaTop_area_entered(area):
	if area.name == "HitboxZone":
		var entity = area.owner
		
#		print("PLAYER: Mob \"" + str(entity.name) + "\" DAMAGE TOP ----> " + str(area.name))
		
		if entity.has_method("simulate_damage"):
			var damage = get_attack_damage()
			entity.simulate_damage(damage, knockback)


func _on_DamageAreaRight_area_entered(area):
	if area.name == "HitboxZone":
		var entity = area.owner
		
#		print("PLAYER: Mob \"" + str(entity.name) + "\" DAMAGE RIGHT ----> " + str(area.name))
		
		if entity.has_method("simulate_damage"):
			var damage = get_attack_damage()
			entity.simulate_damage(damage, knockback)


# Method to simulate damage and behaviour to player
func simulate_damage(enemy_global_position, damage_to_player : int, knockback_to_player : int):
	if not is_invincible:
		# Add damage
		current_health -= damage_to_player
		
		# handle here healthbar
		if current_health <= 0:
			set_current_health(0)
		else:
			set_current_health(current_health)
		
		# Check if player is hurted or killed
		if current_health <= 0:
			kill_player()
		else:
			if not is_attacking and not collected:
				hurt_player()
		
		# Add knockback
		# Caluculate linear function between min_knockback_velocity_factor and max_knockback_velocity_factor to get knockback_velocity_factor depending on knockback between min_knockback_velocity_factor and max_knockback_velocity_factor
		var min_knockback_velocity_factor = Constants.MIN_KNOCKBACK_VELOCITY_FACTOR_TO_PLAYER
		var max_knockback_velocity_factor = Constants.MAX_KNOCKBACK_VELOCITY_FACTOR_TO_PLAYER
		var m = (max_knockback_velocity_factor - min_knockback_velocity_factor) / Constants.MAX_KNOCKBACK
		var knockback_velocity_factor = m * knockback_to_player + min_knockback_velocity_factor
		velocity = enemy_global_position.direction_to(global_position) * knockback_velocity_factor


# Method is called when hurting player
func hurt_player():
	if animation_tree.active: # Because when in menu the animation tree is disabled and the animation is never finished to unlock "hurting"
		hurting = true
	if !collecting:
		set_movement(false)
	sound.stream = Constants.PreloadedSounds.Hurt
	sound.play()
	animation_state.start("Hurt")


# Method is called when HURT animation is done
func player_hurt():
	hurting = false
	if !collecting:
		set_movement(true)
	else:
		animation_state.travel("Collect")


# Method is called when killing player
func kill_player():
	# Make player invisible to mobs
	make_player_invisible(true)
	
	dying = true
	set_movement(false)
	if not animation_tree.active: # Show "Die" animation in all states to call "player_killed"
		animation_tree.active = true
	if is_attacking:
		is_attacking = false
		set_movement(true)
	animation_player.stop(true)
	animation_state.travel("Die")
	
	# Close LootPanel
	if Utils.get_loot_panel() != null:
		Utils.get_loot_panel().queue_free()


# Method is called when player collect loot
func player_collect_loot():
	collecting = true
	set_movement(false)
	set_player_can_interact(false)
	animation_state.travel("Collect")


# Method is called after collecting and the animation go on to finish
func player_looted():
	collected = true
	animation_state.travel("Collected")


# Method is called when loot animation is finished to start other animations
func finished_looting():
	hurting = false
	collecting = false
	set_movement(true)
	set_player_can_interact(true)
	collected = false


# Method is called when DIE animation is done
func player_killed():
	Utils.show_death_screen()
	if Utils.get_ui().get_node_or_null("DialogueBox") != null:
		Utils.get_ui().get_node_or_null("DialogueBox").queue_free()


# Method to return true if player is dying/died otherwise false -> called from scene_manager
func is_player_dying():
	return dying


# Method to reset the players behaviour after dying -> called from scene_manager
func reset_player_after_dying():
	if sound_breath.is_playing():
		sound_breath.stop()
	
	animation_state.start("Idle")
	
	# Make player visible again to mobs
	make_player_invisible(false)
	
	# reset cooldown
	set_health_cooldown(0)
	set_stamina_cooldown(0)
	Utils.get_hotbar().get_node("Hotbar/Timer").stop()
	Utils.get_hotbar()._on_Timer_timeout()
	
	hurting = false
	dying = false
	is_attacking = false
	collecting = false
	set_current_health(max_health)
	set_current_stamina(get_max_stamina())
	set_movment_animation(true)
	set_movement(true)


func get_light_radius():
	return player_light_radius


func set_light(new_light: int):
	player_light_radius = new_light
	data.light = player_light_radius
	$CustomLight.min_radius = new_light * 0.96
	$CustomLight.max_radius= new_light * 1.04


# Method to make to player invisible to mobs or not -> no recognizing/chasing/seeing
func make_player_invisible(invisible : bool):
	if invisible:
		# Remove player from player layer so the mobs wont recognize the player anymore
		set_collision_layer_bit(1, false)
		print("PLAYER: Invisibility == True")
	else:
		# Add player to player layer so the mobs will recognize the player again
		set_collision_layer_bit(1, true)
		print("PLAYER: Invisibility == False")


# Method to get player invisibility
func is_player_invisible():
	if get_collision_layer_bit(1) == true:
		# Player is visible
		return false
	else:
		# Player is invisible
		return true 


# Method to make to player invincible to mobs or not -> no damage
func make_player_invincible(invincible : bool):
	is_invincible = invincible
	print("PLAYER: Invincibility == " + str(is_invincible))


# Method to get player invincibility
func is_player_invincible():
	return is_invincible


# Method to set in_safe_area
func set_in_safe_area(new_in_safe_area):
	in_safe_area = new_in_safe_area
	
	if in_safe_area:
		make_player_invisible(true)
	else:
		make_player_invisible(false)


# Method to get in_safe_area
func is_in_safe_area():
	return in_safe_area


# Method to set in_change_scene_area
func set_in_change_scene_area(new_in_change_scene_area):
	in_change_scene_area = new_in_change_scene_area


# Method to get in_change_scene_area
func is_in_change_scene_area():
	return in_change_scene_area


func rescue_pay():
	# Pay amount of gold
	var lost_gold = int(gold * Constants.RESCUE_PAY_GOLD_FACTOR)
	set_gold(int(gold * (1 - Constants.RESCUE_PAY_GOLD_FACTOR)))
	# Pay an item
	var item_list = []
	for i in range(1,31):
		if PlayerData.inv_data["Inv" + str(i)]["Item"] != null:
			item_list.append(i)
		
	randomize()
	var worth = 0
	var lost_items = []
	# Only lose Item with min level 3 and min 3 items in inventory
	if level >= Constants.MIN_LEVEL_ITEM_LOSE and item_list.size() >= 4:
		# Pay min level * 10 Worth on random Items if possible
		while worth < level * Constants.MIN_LOST_FACTOR and item_list.size() > 3:
			var payed_item = item_list[(randi() % item_list.size())]
			item_list.erase(payed_item)
			if PlayerData.inv_data["Inv" + str(payed_item)]["Stack"] > 1:
				lost_items.append(str(PlayerData.inv_data["Inv" + str(payed_item)]["Stack"]) + " ⨯ " + 
				tr((GameData.item_data[str(PlayerData.inv_data["Inv" + str(payed_item)]["Item"])]["Name"]).to_upper()))
			else:
				lost_items.append(tr((GameData.item_data[str(PlayerData.inv_data["Inv" + str(payed_item)]["Item"])]["Name"]).to_upper()))
			worth += (GameData.item_data[str(PlayerData.inv_data["Inv" + str(payed_item)]["Item"])]["Worth"] * 
			PlayerData.inv_data["Inv" + str(payed_item)]["Stack"])
			PlayerData.inv_data["Inv" + str(payed_item)]["Item"] = null
			PlayerData.inv_data["Inv" + str(payed_item)]["Stack"] = null
	Utils.save_game(true)
	var lost_string = tr("LOST_ITEMS") + ": \n"
	if lost_gold > 0 and lost_items.size() < 4:
		lost_string += " • " + str(lost_gold) + " Gold" + "\n"
	elif lost_gold > 0:
		lost_string += str(lost_gold) + " Gold"
	if lost_items.size() <= 4:
		for item in lost_items:
			lost_string += (" • " + item + "\n")
	else:
		for item in lost_items:
			lost_string += (", " + item)
	var lost_dialog = [{"name":tr("DEATH"), "text": lost_string}]
	if lost_items.size() > 0:
		sound.stream = Constants.PreloadedSounds.Collect2
	else:
		sound.stream = Constants.PreloadedSounds.Collect
	if lost_items.size() > 0 or lost_gold > 0:
		sound.play()
		set_player_can_interact(false)
		set_movement(false)
		pause_player(true)
		var dialog = Constants.PreloadedScenes.DialogScene.instance()
		Utils.get_ui().add_child(dialog)
		dialog.start(self, "Death", lost_dialog)


func set_health_cooldown(new_cooldown):
	health_cooldown = new_cooldown
	# for save
	data.cooldown = new_cooldown


func set_stamina_cooldown(new_cooldown):
	stamina_cooldown = new_cooldown
	# for save
	data.stamina_cooldown = new_cooldown


func destroy_scene():
	print("destroy_scene")
