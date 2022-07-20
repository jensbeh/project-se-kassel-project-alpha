extends Area2D


var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func mob_can_see_player():
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	# Mob recognize player
	if body.name == "Player":
		player = body


func _on_PlayerDetectionZone_body_exited(body):
	# Mob lose player
	if body.name == "Player":
		player = null
