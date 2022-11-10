extends Node2D


# Variables
var current_position


# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = current_position


# Method to init variables, typically called after instancing
func init(death_position):
	current_position = death_position


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		Utils.get_sound_player().stream = Constants.PreloadedSounds.Sucsess
		Utils.get_sound_player().play()
		# Collecting key
		Utils.get_scene_manager().get_current_scene().on_key_collected()
		call_deferred("queue_free")
