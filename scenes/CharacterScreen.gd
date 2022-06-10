extends Node2D ## TODO: Load Character and show, Create List Items with Font

var selected_character = 0
onready var list = $ScrollContainer/MarginContainer/CharacterList
onready var scroll = $ScrollContainer

func _ready():
	change_menu_color()

func change_menu_color():
	if list.get_child_count() != 0:
		list.get_child(selected_character).get_child(0).modulate = Color(0.07, 0.19, 0.86, 1)
		list.get_child(selected_character).get_child(1).get_child(0).modulate = Color(0.07, 0.19, 0.86, 1)
		list.get_child(selected_character).get_child(1).get_child(1).modulate = Color(0.07, 0.19, 0.86, 1)
		
func unchange_menu_color():
	if list.get_child_count() != 0:
		list.get_child(selected_character).get_child(0).modulate = Color(1, 1, 1, 1)
		list.get_child(selected_character).get_child(1).get_child(0).modulate = Color(1, 1, 1, 1)
		list.get_child(selected_character).get_child(1).get_child(1).modulate = Color(1, 1, 1, 1)

func _on_Back_pressed():
	get_tree().change_scene("res://scenes/MainMenuScreen.tscn")

func _on_Create_Character_pressed():
	get_tree().change_scene("res://scenes/CreateCharacter.tscn")
	
func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		unchange_menu_color()
		if selected_character < list.get_child_count()-1:
			selected_character = selected_character + 1
			scroll.set_v_scroll(scroll.get_v_scroll()+70)
		else:
			selected_character = list.get_child_count() -1
		change_menu_color()
	elif Input.is_action_just_pressed("ui_up"):
		unchange_menu_color()
		if selected_character > 0:
			selected_character = selected_character - 1
			scroll.set_v_scroll(scroll.get_v_scroll()-70)
		else:
			selected_character = 0
		change_menu_color()
	elif Input.is_action_just_pressed("enter"):
		# Choose the Selected Character
		pass
