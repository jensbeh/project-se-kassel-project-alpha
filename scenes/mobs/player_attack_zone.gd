extends Area2D

# Signals
signal player_entered_attack_zone
signal player_exited_attack_zone

# Variables
var mob_can_attack : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Method is called when a body entered the attack zone
func _on_PlayerAttackZone_body_entered(body):
	# Mob recognize player
	if body.name == "Player":
		emit_signal("player_entered_attack_zone")
		mob_can_attack = true


# Method is called when a body exited the attack zone
func _on_PlayerAttackZone_body_exited(body):
	# Mob lose player
	if body.name == "Player":
		emit_signal("player_exited_attack_zone")
		mob_can_attack = false
