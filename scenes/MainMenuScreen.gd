extends Node2D

func _ready():
	pass # Replace with function body.


func _on_Start_Game_pressed():
	get_tree().change_scene("res://scenes/CharacterScreen.tscn")


func _on_Settings_pressed():
	get_tree().change_scene("")


func _on_Exit_to_Desktop_pressed():
	get_tree().quit()
