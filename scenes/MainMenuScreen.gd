extends Node2D



func _ready():
	pass # Replace with function body.


func _on_Start_Game_pressed():
	Utils.get_scene_manager().transition_to_scene("res://scenes/CharacterScreen.tscn")

func _on_Settings_pressed():
	pass

func _on_Exit_to_Desktop_pressed():
	get_tree().quit()
