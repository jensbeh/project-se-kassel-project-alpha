extends KinematicBody2D

# Signals
signal player_collided(collision)
signal player_interact

# Animation
onready var animation_tree = $AnimationTree
onready var animation_player = $AnimationPlayer
onready var animation_state = animation_tree.get("parameters/playback")

# Collision
onready var ray = $RayCast2D

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

const CompositeSprites = preload("res://assets/player/CompositeSprites.gd")
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
var movement

# Interaction
var player_can_interact

# player stats and values
var gold: int
var attack_damage: int = 0
var knockback: int = 0
var attack_speed: int = 0
var max_health: int
var current_health: int
var data
var level: int = 1
var dragging = false
var preview = false
var player_exp: int = 0
var player_light_radius: int

# Variables
var is_attacking = false
var can_attack = false
var hurting = false
var dying = false
var is_invincible = false
var collecting = false
var collected = false


func _ready():
	# Style
	bodySprite.texture = CompositeSprites.BODY_SPRITESHEET[curr_body]
	shoesSprite.texture = CompositeSprites.SHOES_SPRITESHEET[curr_shoes]
	pantsSprite.texture = CompositeSprites.PANTS_SPRITESHEET[curr_pants]
	clothesSprite.texture = CompositeSprites.CLOTHES_SPRITESHEET[curr_clothes]
	blushSprite.texture = CompositeSprites.BLUSH_SPRITESHEET[curr_blush]
	lipstickSprite.texture = CompositeSprites.LIPSTICK_SPRITESHEET[curr_lipstick]
	beardSprite.texture = CompositeSprites.BEARD_SPRITESHEET[curr_beard]
	eyesSprite.texture = CompositeSprites.EYES_SPRITESHEET[curr_eyes]
	earringSprite.texture = CompositeSprites.EARRING_SPRITESHEET[curr_earring]
	hairSprite.texture = CompositeSprites.HAIR_SPRITESHEET[curr_hair]
	maskSprite.texture = CompositeSprites.MASK_SPRITESHEET[curr_mask]
	glassesSprite.texture = CompositeSprites.GLASSES_SPRITESHEET[curr_glasses]
	hatSprite.texture = CompositeSprites.HAT_SPRITESHEET[curr_hat]
	
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
	
	# Set invisibility of player
	make_player_invisible(false)
	
	# Set invincibility of player
	make_player_invincible(false)


func _physics_process(delta):
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
			
		if Input.is_action_pressed("Shift"):
			velocity *= 1.4
		
		if velocity != Vector2.ZERO and player_can_interact:
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
			velocity = move_and_slide(velocity)
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision != null and !collision.get_collider().get_parent().get_meta_list().empty():
					emit_signal("player_collided", collision.get_collider())
	
	elif (hurting or dying) and velocity != Vector2.ZERO and not collecting:
		# handle knockback when hurting or dying
		velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
		velocity = move_and_slide(velocity)


# Method handles key inputs
func _input(event):
	Utils.get_control_notes().update()
	
	if event.is_action_pressed("e"):
		
		if player_can_interact:
			emit_signal("player_interact")
			
		# Remove the Loot Panel
		elif Utils.get_ui().get_node_or_null("LootPanel") != null:
			# Call close Method in Loot Panel
			Utils.get_ui().get_node_or_null("LootPanel")._on_Close_pressed()
			
		# Remove the trade inventory
		if Utils.get_trade_inventory() != null and !dragging:
			Utils.get_trade_inventory().queue_free()
			set_player_can_interact(true)
			set_movement(true)
			set_movment_animation(true)
			# Reset npc interaction state
			for npc in Utils.get_scene_manager().get_current_scene().find_node("npclayer").get_children():
				npc.set_interacted(false)
			PlayerData.save_inventory()
			save_player_data(Utils.get_current_player().get_data())
			MerchantData.save_merchant_inventory()
		
	# Open game menu with "esc"
	elif event.is_action_pressed("esc") and movement and not hurting and not dying and Utils.get_game_menu() == null:
		set_movement(false)
		set_movment_animation(false)
		set_player_can_interact(false)
		Utils.get_ui().add_child(load(Constants.GAME_MENU_PATH).instance())
		save_player_data(Utils.get_current_player().get_data())
		PlayerData.save_inventory()
	# Close game menu with "esc" when game menu is open
	elif event.is_action_pressed("esc") and !movement and Utils.get_game_menu() != null:
		set_movement(true)
		set_movment_animation(true)
		set_player_can_interact(true)
		Utils.get_game_menu().queue_free()
	
	# Open character inventory with "i"
	elif event.is_action_pressed("character_inventory") and movement and not hurting and not dying and Utils.get_character_interface() == null:
		set_movement(false)
		set_movment_animation(false)
		set_player_can_interact(false)
		Utils.get_ui().add_child(load(Constants.CHARACTER_INTERFACE_PATH).instance())
	# Close character inventory with "i"
	elif event.is_action_pressed("character_inventory") and !movement and Utils.get_character_interface() != null and !dragging:
		set_movement(true)
		set_movment_animation(true)
		set_player_can_interact(true)
		PlayerData.inv_data["Weapon"] = PlayerData.equipment_data["Weapon"]
		PlayerData.inv_data["Light"] = PlayerData.equipment_data["Light"]
		PlayerData.inv_data["Hotbar"] = PlayerData.equipment_data["Hotbar"]
		PlayerData.save_inventory()
		save_player_data(Utils.get_current_player().get_data())
		Utils.get_character_interface().queue_free()
	
	# Use Item from Hotbar
	elif event.is_action_pressed("hotbar") and !preview:
		Utils.get_hotbar().use_item()
		
	# Control Notes
	elif event.is_action_pressed("control_notes") and !preview:
		Utils.get_control_notes().show_hide_control_notes()
	
	# Attack with "left_mouse"
	elif event.is_action_pressed("attack") and not is_attacking and can_attack and movement and not hurting and not dying and not collecting:
		is_attacking = true
		set_movement(false)
		animation_state.start("Attack")
	
	# Loot All
	elif event.is_action_pressed("loot_all") and Utils.get_ui().get_node_or_null("LootPanel") != null:
		# Call Loot all Method in Loot Panel
		Utils.get_ui().get_node_or_null("LootPanel")._on_LootAll_pressed()


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
	current_walk_speed *= factor


# Method to activate or deactivate the movment state
func set_movement(can_move : bool):
	movement = can_move


# Method to return the movment state
func get_movement() -> bool:
	return movement


# Method to reset the player walk speed to const
func reset_speed():
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
			bodySprite.texture = CompositeSprites.BODY_SPRITESHEET[curr_body]
		"curr_shoes":
			curr_shoes = value
			shoesSprite.texture = CompositeSprites.SHOES_SPRITESHEET[curr_shoes]
		"curr_pants":
			curr_pants = value
			pantsSprite.texture = CompositeSprites.PANTS_SPRITESHEET[curr_pants]
		"curr_clothes":
			curr_clothes = value
			clothesSprite.texture = CompositeSprites.CLOTHES_SPRITESHEET[curr_clothes]
		"curr_blush":
			curr_blush = value
			blushSprite.texture = CompositeSprites.BLUSH_SPRITESHEET[curr_blush]
		"curr_lipstick":
			curr_lipstick = value
			lipstickSprite.texture = CompositeSprites.LIPSTICK_SPRITESHEET[curr_lipstick]
		"curr_beard":
			curr_beard = value
			beardSprite.texture = CompositeSprites.BEARD_SPRITESHEET[curr_beard]
		"curr_eyes":
			curr_eyes = value
			eyesSprite.texture = CompositeSprites.EYES_SPRITESHEET[curr_eyes]
		"curr_earring":
			curr_earring = value
			earringSprite.texture = CompositeSprites.EARRING_SPRITESHEET[curr_earring]
		"curr_hair":
			curr_hair = value
			hairSprite.texture = CompositeSprites.HAIR_SPRITESHEET[curr_hair]
		"curr_mask":
			curr_mask = value
			maskSprite.texture = CompositeSprites.MASK_SPRITESHEET[curr_mask]
		"curr_glasses":
			curr_glasses = value
			glassesSprite.texture = CompositeSprites.GLASSES_SPRITESHEET[curr_glasses]
		"curr_hat":
			curr_hat = value
			hatSprite.texture = CompositeSprites.HAT_SPRITESHEET[curr_hat]


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
func set_spawn(spawn_position: Vector2, view_direction: Vector2):
	animation_tree.active = false # Otherwise player_view_direction won't change
	animation_tree.set("parameters/Idle/blend_position", view_direction)
	animation_tree.set("parameters/Walk/blend_position", view_direction)
	animation_tree.set("parameters/Hurt/blend_position", velocity)
	animation_tree.set("parameters/Collect/blend_position", velocity)
	animation_tree.set("parameters/Collected/blend_position", velocity)
	animation_tree.set("parameters/Attack/AttackCases/blend_position", view_direction)
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
	if new_weapon_id != null:
		var weapon_id_str = str(new_weapon_id)
		can_attack = true
		var weapons_dir = Directory.new()
		var weapon_path = ""
		if weapons_dir.open("res://assets/player/weapons/") == OK:
			weapons_dir.list_dir_begin()
			var weapon_name : String = weapons_dir.get_next()
			while weapon_name != "":
				if weapon_name.ends_with(".png"):
					var file_weapon_id = weapon_name.substr(weapon_name.find_last("_") + 1, 5)
					if file_weapon_id == weapon_id_str:
						weapon_path = "res://assets/player/weapons/" + weapon_name
						break
					
				weapon_name = weapons_dir.get_next()
		
		
		var weapon_texture = load(weapon_path)
		weaponSprite.texture = weapon_texture
	
	else:
		can_attack = false
		
		
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
	if random_float <= Constants.AttackDamageStatesWeights[Constants.AttackDamageStates.CRITICAL_ATTACK]:
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


func set_data(new_data):
	data = new_data


func get_data():
	return data


func save_player_data(player_data):
	var dir = Directory.new()
	if !dir.dir_exists(Constants.SAVE_PATH):
		dir.make_dir(Constants.SAVE_PATH)
	var save_game = File.new()
	save_game.open(Constants.SAVE_PATH + player_data.id + ".json", File.WRITE)
	save_game.store_line(to_json(player_data))
	save_game.close()


func set_preview(value):
	preview = value


func set_dragging(value):
	dragging = value


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


func _on_DamageAreaBottom_area_entered(area):
	if area.name == "HitboxZone":
		var entity = area.owner
		
#		print("MOB \"" + str(entity.name) + "\" DAMAGE BOTTOM ----> " + str(area.name))
		
		if entity.has_method("simulate_damage"):
			var damage = get_attack_damage()
			entity.simulate_damage(damage, knockback)


func _on_DamageAreaLeft_area_entered(area):
	if area.name == "HitboxZone":
		var entity = area.owner
		
#		print("MOB \"" + str(entity.name) + "\" DAMAGE LEFT ----> " + str(area.name))
		
		if entity.has_method("simulate_damage"):
			var damage = get_attack_damage()
			entity.simulate_damage(damage, knockback)


func _on_DamageAreaTop_area_entered(area):
	if area.name == "HitboxZone":
		var entity = area.owner
		
#		print("MOB \"" + str(entity.name) + "\" DAMAGE TOP ----> " + str(area.name))
		
		if entity.has_method("simulate_damage"):
			var damage = get_attack_damage()
			entity.simulate_damage(damage, knockback)


func _on_DamageAreaRight_area_entered(area):
	if area.name == "HitboxZone":
		var entity = area.owner
		
#		print("MOB \"" + str(entity.name) + "\" DAMAGE RIGHT ----> " + str(area.name))
		
		if entity.has_method("simulate_damage"):
			var damage = get_attack_damage()
			entity.simulate_damage(damage, knockback)


# Method to simulate damage and behaviour to player
func simulate_damage(enemy_global_position, damage_to_player : int, knockback_to_player : int):
	if not is_invincible:
		# Add damage
		current_health -= damage_to_player
		
#		print("health: " + str(current_health))
#		print("max_health: " + str(max_health))
#		print("damage_to_player: " + str(damage_to_player))
#		print("knockback_to_player: " + str(knockback_to_player))
		
		
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
		var min_knockback_velocity_factor = 25
		var max_knockback_velocity_factor = 100
		var m = (max_knockback_velocity_factor - min_knockback_velocity_factor) / Constants.MAX_KNOCKBACK
		var knockback_velocity_factor = m * knockback_to_player + min_knockback_velocity_factor
		velocity = enemy_global_position.direction_to(global_position) * knockback_velocity_factor


# Method is called when hurting player
func hurt_player():
	if animation_tree.active: # Because when in menu the animation tree is disabled and the animation is never finished to unlock "hurting"
		hurting = true
	if !collecting:
		set_movement(false)
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
	if Utils.get_ui().get_node_or_null("LootPanel") != null:
		Utils.get_ui().get_node_or_null("LootPanel").queue_free()


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
	Utils.get_main().show_death_screen()
	if Utils.get_ui().get_node_or_null("DialogueBox") != null:
		Utils.get_ui().get_node_or_null("DialogueBox").queue_free()


# Method to return true if player is dying/died otherwise false -> called from scene_manager
func is_player_dying():
	return dying


# Method to reset the players behaviour after dying -> called from scene_manager
func reset_player_after_dying():
	# Make player visible again to mobs
	make_player_invisible(false)
	
	# reset cooldown
	Utils.get_hotbar().get_node("Hotbar/Timer").stop()
	Utils.get_hotbar()._on_Timer_timeout()
	
	set_current_health(max_health)
	hurting = false
	dying = false
	is_attacking = false
	collecting = false
	set_movment_animation(true)
	set_movement(true)
	animation_state.start("Idle")

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
		print("---> PLAYER VISIBILITY: False")
	else:
		# Add player to player layer so the mobs will recognize the player again
		set_collision_layer_bit(1, true)
		print("---> PLAYER VISIBILITY: True")


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
	print("---> PLAYER INVINCIBILITY: " + str(is_invincible))


# Method to get player invincibility
func is_player_invincible():
	return is_invincible
	
