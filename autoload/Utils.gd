extends Node

func _ready():
	pass

func get_player():
	return get_node("/root/SceneManager/CurrentScene").get_children().back().find_node("Player")
