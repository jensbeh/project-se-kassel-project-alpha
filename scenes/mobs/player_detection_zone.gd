extends Area2D


var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_deferred("monitoring", true)
	$DetectionShape.set_deferred("disabled", false)


func mob_can_see_player():
	return player != null


# Method is called when a body entered the detection zone
func _on_PlayerDetectionZone_body_entered(body):
	# Mob recognize player
	if body.name == "Player":
		player = body


# Method is called when a body exited the detection zone
func _on_PlayerDetectionZone_body_exited(body):
	# Mob lose player
	if body.name == "Player":
		player = null
