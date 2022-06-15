extends KinematicBody2D

# Signals
signal player_collided(collision)

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

const composite_sprites = preload("res://assets/player/CompositeSprites.gd")

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
var curr_hair: int = 0 #0-14, 14
var curr_mask: int = 0 #0-2, 1
var curr_glasses: int = 0 #0-1, 10
var curr_hat: int = 0 #0-4, 1

# Walk
const WALK_SPEED = 50
var velocity = Vector2(0,1)


func _ready():
	# Style
	bodySprite.texture = composite_sprites.body_spritesheet[curr_body]
	shoesSprite.texture = composite_sprites.shoes_spritesheet[curr_shoes]
	pantsSprite.texture = composite_sprites.pants_spritesheet[curr_pants]
	clothesSprite.texture = composite_sprites.clothes_spritesheet[curr_clothes]
	blushSprite.texture = composite_sprites.blush_spritesheet[curr_blush]
	lipstickSprite.texture = composite_sprites.lipstick_spritesheet[curr_lipstick]
	beardSprite.texture = composite_sprites.beard_spritesheet[curr_beard]
	eyesSprite.texture = composite_sprites.eyes_spritesheet[curr_eyes]
	earringSprite.texture = composite_sprites.earring_spritesheet[curr_earring]
	hairSprite.texture = composite_sprites.hair_spritesheet[curr_hair]
	maskSprite.texture = composite_sprites.mask_spritesheet[curr_mask]
	glassesSprite.texture = composite_sprites.glasses_spritesheet[curr_glasses]
	hatSprite.texture = composite_sprites.hat_spritesheet[curr_hat]
	
	shadow.visible = false
	
	# Sets the Visibility of a given Sprite
	set_visibility(maskSprite, false) #Sprite, true/false 
	set_visibility(glassesSprite, false)
	set_visibility(earringSprite, false)
	set_visibility(hatSprite, false)

	# Animation
	animation_tree.active = true
	animation_tree.set("parameters/Idle/blend_position", velocity)
	animation_tree.set("parameters/Walk/blend_position", velocity)
	

func _physics_process(_delta):
	# Handle User Input
	if Input.is_action_pressed("d") or Input.is_action_pressed("a"):
		velocity.x = (int(Input.is_action_pressed("d")) - int(Input.is_action_pressed("a"))) * WALK_SPEED
	else:
		velocity.x = 0
		
	if Input.is_action_pressed("s") or Input.is_action_pressed("w"):
		velocity.y = (int(Input.is_action_pressed("s")) - int(Input.is_action_pressed("w"))) * WALK_SPEED
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
		
	move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision != null and !collision.get_collider().get_parent().get_meta_list().empty():
			emit_signal("player_collided", collision.get_collider())		


# Sets the Visibility of a given Sprite
func set_visibility(sprite, value):
	sprite.visible = value


# Sets the current texture
func set_texture(name, value):
	match name:
		"curr_body":
			curr_body = value
			bodySprite.texture = composite_sprites.body_spritesheet[curr_body]
		"curr_shoes":
			curr_shoes = value
			shoesSprite.texture = composite_sprites.shoes_spritesheet[curr_shoes]
		"curr_pants":
			curr_pants = value
			pantsSprite.texture = composite_sprites.pants_spritesheet[curr_pants]
		"curr_clothes":
			curr_clothes = value
			clothesSprite.texture = composite_sprites.clothes_spritesheet[curr_clothes]
		"curr_blush":
			curr_blush = value
			blushSprite.texture = composite_sprites.blush_spritesheet[curr_blush]
		"curr_lipstick":
			curr_lipstick = value
			lipstickSprite.texture = composite_sprites.lipstick_spritesheet[curr_lipstick]
		"curr_beard":
			curr_beard = value
			beardSprite.texture = composite_sprites.beard_spritesheet[curr_beard]
		"curr_eyes":
			curr_eyes = value
			eyesSprite.texture = composite_sprites.eyes_spritesheet[curr_eyes]
		"curr_earring":
			curr_earring = value
			earringSprite.texture = composite_sprites.earring_spritesheet[curr_earring]
		"curr_hair":
			curr_hair = value
			hairSprite.texture = composite_sprites.hair_spritesheet[curr_hair]
		"curr_mask":
			curr_mask = value
			maskSprite.texture = composite_sprites.mask_spritesheet[curr_mask]
		"curr_glasses":
			curr_glasses = value
			glassesSprite.texture = composite_sprites.glasses_spritesheet[curr_glasses]
		"curr_hat":
			curr_hat = value
			hatSprite.texture = composite_sprites.hat_spritesheet[curr_hat]


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
	print(value, "value")
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1), 
	newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1)) + value)
	print(newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1)), "set0")
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.1, 1), 
	newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.1, 1)) + value)
	print(newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.1, 1)), "set1")
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.2, 1), 
	newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.2, 1)) + value)
	print(newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.2, 1)), "set2")
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.3, 1), 
	newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.3, 1)) + value)
	print(newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.3, 1)), "set3")
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.4, 1), 
	newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.4, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.5, 1), 
	newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.5, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.6, 1), 
	newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.6, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.7, 1), 
	newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.7, 1)) + value)
	print(newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.7, 1)), "se7")
