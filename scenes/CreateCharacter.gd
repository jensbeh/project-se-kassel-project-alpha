extends Node2D


func _ready():
	pass # Replace with function body.


func _on_Back_pressed():
	Utils.get_scene_manager().transition_to_scene("res://scenes/CharacterScreen.tscn")


func _on_Create_Character_pressed():
	pass # Replace with function body.
