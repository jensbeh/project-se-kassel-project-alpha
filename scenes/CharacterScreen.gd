extends Node2D ## TODO: Load Character and show, Bug: syncronize mouse click and keyboard

var selected_character = 0
var style2 = StyleBoxFlat.new()
var style1 = StyleBoxFlat.new()

onready var list = $ScrollContainer/MarginContainer/CharacterList
onready var scroll = $ScrollContainer

func _ready():
	# Create Selected Style
	style2.set_bg_color(Color(0.6, 0.6, 0.6, 1))
	style1.set_bg_color(Color(0.5, 0.5, 0.5, 1))
	style1.set_corner_radius_all(5)
	
	# Auto Scroll activated
	scroll.set_follow_focus(true)
	for i in list.get_children():
		i.set_focus_mode(2)
	
	# Set first Selected
	change_menu_color()
	if list.get_child_count() != 0:
		list.get_child(0).grab_focus()
	
	create_item("Test", 12, 200)
	create_item("Test1", 2, 100)
	create_item("Test2", 1, 100)
	create_item("Test3", 4, 100)
	create_item("Test4", 3, 100)
	

# create Character Item to Choose
func create_item(charac_name, charac_level, charac_gold):
	var container = MarginContainer.new()
	var panel = Panel.new()
	panel.add_stylebox_override("panel", style2)
	container.add_child(panel)
	var mcontainer = MarginContainer.new()
	mcontainer.add_constant_override("margin_top", 10)
	mcontainer.add_constant_override("margin_left", 10)
	mcontainer.add_constant_override("margin_bottom", 10)
	var vbox = VBoxContainer.new()
	vbox.add_constant_override("separation", 10)
	var name = Label.new()
	name.set_text("Name: " + charac_name)
	var font = DynamicFont.new()
	font.font_data = load("res://assets/Hack_Regular.ttf")
	font.set_size(25)
	font.set_outline_color(0xffffff)
	name.add_font_override("font", font)
	vbox.add_child(name)
	var hbox = HBoxContainer.new()
	hbox.add_constant_override("separation", 50)
	var gold = Label.new()
	gold.set_text("Gold: " + var2str(charac_gold))
	gold.add_font_override("font", font)
	hbox.add_child(gold)
	var level = Label.new()
	level.set_text("Level: " + var2str(charac_level))
	level.add_font_override("font", font)
	hbox.add_child(level)
	vbox.add_child(hbox)
	mcontainer.add_child(vbox)
	mcontainer.set_script(load("res://scenes/MarginContainerScript.gd"))
	mcontainer.connect("gui_input", mcontainer, "_on_MarginContainer_gui_input")
	container.add_child(mcontainer) 
	container.set_focus_mode(2)
	list.add_child(container)
	
	
# set unselected style
func unchange_menu_color():
	if list.get_child_count() != 0:
		for i in list.get_child_count():
			list.get_child(i).get_child(0).add_stylebox_override("panel", style2)

# set select style
func change_menu_color():
	if list.get_child_count() != 0:
		list.get_child(selected_character).get_child(0).add_stylebox_override("panel", style1)


func _on_Back_pressed():
	Utils.get_scene_manager().transition_to_scene("res://scenes/MainMenuScreen.tscn")


func _on_Create_Character_pressed():
	Utils.get_scene_manager().transition_to_scene("res://scenes/CreateCharacter.tscn")


func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		unchange_menu_color()
		if selected_character < list.get_child_count()-1:
			selected_character = selected_character + 1
			list.get_child(selected_character).grab_focus()
		print(selected_character)
		change_menu_color()
	elif Input.is_action_just_pressed("ui_up"):
		unchange_menu_color()
		if selected_character > 0:
			selected_character = selected_character - 1
			list.get_child(selected_character).grab_focus()
		print(selected_character)
		change_menu_color()
	elif Input.is_action_just_pressed("enter"):
		Utils.get_scene_manager().transition_to_scene("res://scenes/Camp.tscn")
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			unchange_menu_color()
