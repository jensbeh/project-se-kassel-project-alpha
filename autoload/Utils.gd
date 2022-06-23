extends Node

var current_player : KinematicBody2D = null

func _ready():
	pass

func get_player():
	return get_node("/root/SceneManager/CurrentScene").get_children().back().find_node("Player")

func set_current_player(new_current_player: KinematicBody2D):
	current_player = new_current_player
func get_current_player():
	return current_player


func get_scene_manager():
	return get_node("/root/SceneManager")
