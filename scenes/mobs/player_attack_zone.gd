extends Area2D

var mob_can_attack : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_PlayerAttackZone_body_entered(body):
	# Mob recognize player
	if body.name == "Player":
		mob_can_attack = true


func _on_PlayerAttackZone_body_exited(body):
	# Mob lose player
	if body.name == "Player":
		mob_can_attack = false
