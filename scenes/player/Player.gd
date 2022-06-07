extends KinematicBody2D

#Animation
onready var animation_tree = $AnimationTree
onready var animation_player = $AnimationPlayer
onready var animation_state = animation_tree.get("parameters/playback")

#Collision
onready var ray = $RayCast2D

#Look
onready var shadow = $Shadow
onready var bodySprite = $Body
onready var clothesSprite = $Clothes
onready var pantsSprite = $Pant
onready var shoesSprite = $Shoes
onready var beardSprite = $Beard
onready var earringSprite = $Earring
onready var glassesSprite = $Glasses
onready var hatSprite = $Hat
onready var maskSprite = $Mask
onready var hairSprite = $Hair
onready var eyesSprite = $Eyes
onready var lipstickSprite = $Lipstick
onready var blushSprite = $Blush

const composite_sprites = preload("res://assets/player/CompositeSprites.gd")

var curr_body: int = 0 #0-8
var curr_clothes: int = 0 #0-14
var curr_hair: int = 0 #0-14
var curr_eyes: int = 0 #0
var curr_lipstick: int = 0 #0
var curr_blush: int = 0 #0
var curr_pants: int = 0 #0-2
var curr_shoes: int = 0 #0
var curr_beard: int = 0 #0
var curr_earring: int = 0 #0-3
var curr_glasses: int = 0 #0-1
var curr_hat: int = 0 #0-4
var curr_mask: int = 0 #0-2

#Walk
const WALK_SPEED = 50
var velocity = Vector2(0,1)


func _ready():
	#Style
	bodySprite.texture = composite_sprites.body_spritesheet[curr_body]
	hairSprite.texture = composite_sprites.hair_spritesheet[curr_hair]
	clothesSprite.texture = composite_sprites.clothes_spritesheet[curr_clothes]
	eyesSprite.texture = composite_sprites.eyes_spritesheet[curr_eyes]
	lipstickSprite.texture = composite_sprites.lipstick_spritesheet[curr_lipstick]
	blushSprite.texture = composite_sprites.blush_spritesheet[curr_blush]
#	pantsSprite.texture = composite_sprites.pants_spritesheet[curr_pants]
#	shoesSprite.texture = composite_sprites.shoes_spritesheet[curr_shoes]
#	beardSprite.texture = composite_sprites.beard_spritesheet[curr_beard]
#	earringSprite.texture = composite_sprites.earring_spritesheet[curr_earring]
#	glassesSprite.texture = composite_sprites.glasses_spritesheet[curr_glasses]
#	hatSprite.texture = composite_sprites.hat_spritesheet[curr_hat]
#	maskSprite.texture = composite_sprites.mask_spritesheet[curr_mask]
	
	shadow.visible = false
	
	set_invisible(clothesSprite, true) #Sprite, true/false 
	_set_key_walk(2, 64)#Track_idx, +Frame #8er steps by walk

	#Animation
	animation_tree.active = true
	animation_tree.set("parameters/Idle/blend_position", velocity)
	animation_tree.set("parameters/Walk/blend_position", velocity)
	

func _physics_process(delta):
	#Handle User Input
	if Input.is_action_pressed("d") or Input.is_action_pressed("a"):
		velocity.x = (int(Input.is_action_pressed("d")) - int(Input.is_action_pressed("a"))) * WALK_SPEED
	else:
		velocity.x = 0
		
	if Input.is_action_pressed("s") or Input.is_action_pressed("w"):
		velocity.y = (int(Input.is_action_pressed("s")) - int(Input.is_action_pressed("w"))) * WALK_SPEED
	else:
		velocity.y = 0
	
	if velocity != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", velocity)
		animation_tree.set("parameters/Walk/blend_position", velocity)
		animation_state.travel("Walk")
	else:
		animation_state.travel("Idle")
	
	var motion = velocity * delta
	move_and_collide(motion)


# visible/invisible of Sprites
func set_invisible(sprite, value):
	sprite.visible = value


#Track Key Value change for Colors
func _set_key_walk(track_idx, value):
	var newDown = animation_player.get_animation("WalkDown")
	set_key(newDown, track_idx, value)
	
	var newUp = animation_player.get_animation("WalkUp")
	set_key(newUp, track_idx, value)
	
	var newRight = animation_player.get_animation("WalkRight")
	set_key(newRight, track_idx, value)
	
	var newLeft = animation_player.get_animation("WalkLeft")
	set_key(newLeft, track_idx, value)
	
	animation_player.get_animation("IdleDown").track_set_key_value(track_idx, animation_player.get_animation("IdleDown").track_find_key(track_idx, 0.0, 1), animation_player.get_animation("IdleDown").track_get_key_value(track_idx, newDown.track_find_key(track_idx, 0.0, 1)) + value)
	animation_player.get_animation("IdleUp").track_set_key_value(track_idx, animation_player.get_animation("IdleUp").track_find_key(track_idx, 0.0, 1), animation_player.get_animation("IdleUp").track_get_key_value(track_idx, newDown.track_find_key(track_idx, 0.0, 1)) + value)
	animation_player.get_animation("IdleLeft").track_set_key_value(track_idx, animation_player.get_animation("IdleLeft").track_find_key(track_idx, 0.0, 1), animation_player.get_animation("IdleLeft").track_get_key_value(track_idx, newDown.track_find_key(track_idx, 0.0, 1)) + value)
	animation_player.get_animation("IdleRight").track_set_key_value(track_idx, animation_player.get_animation("IdleRight").track_find_key(track_idx, 0.0, 1), animation_player.get_animation("IdleRight").track_get_key_value(track_idx, newDown.track_find_key(track_idx, 0.0, 1)) + value)

func set_key(newAnimation, track_idx, value):
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1), newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.0, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.1, 1), newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.1, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.2, 1), newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.2, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.3, 1), newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.3, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.4, 1), newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.4, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.5, 1), newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.5, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.6, 1), newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.6, 1)) + value)
	newAnimation.track_set_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.7, 1), newAnimation.track_get_key_value(track_idx, newAnimation.track_find_key(track_idx, 0.7, 1)) + value)
