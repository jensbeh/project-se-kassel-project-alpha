extends Node2D

var selected_character = 0
onready var list = $ScrollContainer/MarginContainer/CharacterList

func _ready():
	change_menu_color()
	

func change_menu_color():
	list.get_child(0).get_child(0).modulate = Color(0x00ff4c)


func _on_Back_pressed():
	get_tree().change_scene("res://scenes/MainMenuScreen.tscn")


func _on_Create_Character_pressed():
	get_tree().change_scene("res://scenes/CreateCharacter.tscn")
