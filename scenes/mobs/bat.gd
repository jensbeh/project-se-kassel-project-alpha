extends KinematicBody2D

# Variables
enum {
	IDLING,
	WANDERING,
	HUNTING
}
var velocity = Vector2(0, 0)
var state = IDLING

# Mob movment
var acceleration = 300
var max_speed = 50
var friction = 200

var speed = 100
var threshold = 16
var path = []
var navigation = null

# Nodes
onready var mobSprite = $AnimatedSprite
onready var playerDetectionZone = $PlayerDetectionZone

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	navigation = owner.navigation
	print(owner.navigation)



func _physics_process(delta):
#	match state:
#		IDLING:
#			velocity = velocity.move_toward(Vector2(0, 0), friction * delta)
#			search_player()
#
#		WANDERING:
#			pass
#
#		HUNTING:
#			var player = playerDetectionZone.player
#			if player != null:
#				var direction = (player.global_position - global_position).normalized()
#				velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
#			else:
#				state = IDLING
#			mobSprite.flip_h = velocity.x > 0
#
#	# Move Bat
#	velocity = move_and_slide(velocity)


	if path.size() == 0:
		var player = playerDetectionZone.player
		if player != null:
			get_player_path(player.global_position)

	if path.size() > 0:
		move_to_player()

func move_to_player():
	if global_position.distance_to(path[0]) < threshold:
		path.remove(0)
	else:
		var direction = global_position.direction_to(path[0])
		velocity = direction * speed
		velocity = move_and_slide(velocity)

func get_player_path(player_pos):
	path = navigation.get_simple_path(global_position, player_pos, false)

func search_player():
	if playerDetectionZone.mob_can_see_player():
		# Player in detection zone of this mob
		state = HUNTING
