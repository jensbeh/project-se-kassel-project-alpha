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

	# Animation
	animation_tree.active = true
	animation_tree.set("parameters/Idle/blend_position", velocity)
	animation_tree.set("parameters/Walk/blend_position", velocity)
	

func _physics_process(_delta):
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
	
	if velocity != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", velocity)
		animation_tree.set("parameters/Walk/blend_position", velocity)
		animation_state.travel("Walk")
	else:
		animation_state.travel("Idle")
	
	if movement:	
		velocity = move_and_slide(velocity)
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision != null and !collision.get_collider().get_parent().get_meta_list().empty():
				emit_signal("player_collided", collision.get_collider())		

# Method handles key inputs
func _input(event):
	if event.is_action_pressed("e"):
		print("Pressed e")
		if player_can_interact:
			print("interacted")
			emit_signal("player_interact")
		if Utils.get_scene_manager().find_node("Inventory").visible == true:
			Utils.get_scene_manager().find_node("Inventory").visible = false
			Utils.get_scene_manager().get_node("TradeInventory").queue_free()
			Utils.get_current_player().set_player_can_interact(true)
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			# reset npc interaction state
			for npc in Utils.get_scene_manager().get_child(0).get_child(0).find_node("npclayer").get_children():
				npc.set_interacted(false)

# Method to activate or disable the possibility of interaction
func set_player_can_interact(value):
	player_can_interact = value

# Method to get activate or disable state of possibility of interaction
func get_player_can_interact():
	return player_can_interact

# Method to set a new player walk speed with a factor
func set_speed(factor: float):
	current_walk_speed *= factor

func set_movement(value):
	movement = value

func get_movement():
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


func reset_key(track_idx):
	var newAnimation = animation_player.get_animation("WalkDown")
	var newValue = 1 - newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1))
	_set_key(track_idx, newValue)

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
