extends Node2D ## TODO: load character with mouse click, Bug: syncronize mouse click and keyboard

const SAVE_PATH = "user://"
const SAVE_FILE_EXTENSION = ".json"

var selected_character = 0
var style2 = StyleBoxFlat.new()
var style1 = StyleBoxFlat.new()

onready var list = $ScrollContainer/MarginContainer/CharacterList
onready var scroll = $ScrollContainer

var data_list = []
var body
var shoes
var pants
var clothes
var blush
var lipstick
var beard
var eyes
var hair

func _ready():
	# Create Selected Style
	style2.set_bg_color(Color(0.6, 0.6, 0.6, 1))
	style1.set_bg_color(Color(0.5, 0.5, 0.5, 1))
	style1.set_corner_radius_all(5)
	
	load_data()
	
	# Auto Scroll activated
	scroll.set_follow_focus(true)
	for i in list.get_children():
		i.set_focus_mode(2)
	
	# Set first Selected
	change_menu_color()
	if list.get_child_count() != 0:
		list.get_child(0).grab_focus()
		Utils.get_player().visible = true
	else:
		Utils.get_player().visible = false
	Utils.get_player().set_movement(false)
	
	for child in Utils.get_player().get_children():
		match child.name:
			"Body":
				body = child
			"Shoes":
				shoes = child
			"Pants":
				pants = child
			"Clothes":
				clothes = child
			"Blush":
				blush = child
			"Lipstick":
				lipstick = child
			"Beard":
				beard = child
			"Eyes":
				eyes = child
			"Hair":
				hair = child
				
	
	call_deferred("load_character")

	
# loaded the player data
func load_data():
	var dir = Directory.new()
	dir.open(SAVE_PATH)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif ((!file.begins_with(".")) and (file.ends_with(".json"))):
			var save_game = File.new()
			save_game.open(SAVE_PATH + file, File.READ)
			var save_game_data = {}
			save_game_data = parse_json(save_game.get_line())
			save_game.close()
			data_list.append(save_game_data)
			var name = save_game_data.name
			var gold = save_game_data.gold
			var level = save_game_data.level
			create_item(name, level, gold)
	dir.list_dir_end()
	

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
	mcontainer.connect("click", self, "on_click", [mcontainer.get_instance_id()])
	mcontainer.connect("double_click", self, "on_double_click")
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


func _input(_event):
	if Input.is_action_just_pressed("ui_down"):
		unchange_menu_color()
		if selected_character < list.get_child_count()-1:
			selected_character = selected_character + 1
			list.get_child(selected_character).grab_focus()
			load_character()
		change_menu_color()
	elif Input.is_action_just_pressed("ui_up"):
		unchange_menu_color()
		if selected_character > 0:
			selected_character = selected_character - 1
			list.get_child(selected_character).grab_focus()
			load_character()
		change_menu_color()
	elif Input.is_action_just_pressed("enter"):
		Utils.get_scene_manager().transition_to_scene("res://scenes/Camp.tscn")
		Utils.get_player().set_movement(true)
		load_character()


func on_click(id):
	for item in list.get_children():
		if item.get_child(1).get_instance_id() == id:
			unchange_menu_color()
			selected_character = item.get_index()
			load_character()


func on_double_click():
	Utils.get_scene_manager().transition_to_scene("res://scenes/Camp.tscn")
	Utils.get_player().set_movement(true)
	load_character()


func load_character():
	if data_list != []:
		var data = data_list[selected_character]
		var player = Utils.get_player()
		# set the clothes ...
		hair.frame = (data.hair_color*8)
		player.set_texture("curr_body", data.skincolor)
		body.frame = 0
		player.set_texture("curr_clothes", data.torso)
		clothes.frame = (data.torso_color*8)
		pants.frame = (data.legs_color*8)
		player.set_texture("curr_pants", data.legs)
		shoes.frame = (data.shoe_color*8)
		eyes.frame = (data.eyes_color*8)
		if data.beard_color == 0:
			player.set_visibility("Beard", false)
			beard.frame = ((data.beard_color)*8)
		else: 
			player.set_visibility("Beard", true)
			beard.frame = ((data.beard_color-1)*8)
		if data.blush_color == 0:
			player.set_visibility("Blush", false)
			blush.frame = ((data.blush_color)*8)
		else: 
			player.set_visibility("Blush", true)
			blush.frame = ((data.blush_color-1)*8)
		if data.lipstick_color == 0:
			player.set_visibility("Lipstick", false)
			lipstick.frame = ((data.lipstick_color)*8)
		else: 
			player.set_visibility("Lipstick", true)
			lipstick.frame = ((data.lipstick_color-1)*8)
		if data.hairs == 0:
			player.set_visibility("Hair", false)
			player.set_texture("curr_hair", data.hairs)
		else: 
			player.set_visibility("Hair", true)
			player.set_texture("curr_hair", data.hairs-1)
		set_animation_data()


func set_animation_data():
	var data = data_list[selected_character]
	var player = Utils.get_player()
	# set the animation colors
	player.reset_key(9)
	player._set_key(9, data.hair_color*8)
	player.reset_key(3)
	player._set_key(3, data.torso_color*8)
	player.reset_key(2)
	player._set_key(2, data.legs_color*8)
	player.reset_key(1)
	player._set_key(1, data.shoe_color*8)
	player.reset_key(7)
	player._set_key(7, data.eyes_color*8)
	player.reset_key(6)
	if data.beard_color == 0:
		player._set_key(6, data.beard_color*8)
	else: 
		player._set_key(6, (data.beard_color-1)*8)
	player.reset_key(4)
	if data.blush_color == 0:
		player._set_key(4, data.blush_color*8)
	else: 
		player._set_key(4, (data.blush_color-1)*8)
	player.reset_key(5)
	if data.lipstick_color == 0:
		player._set_key(5, data.lipstick_color*8)
	else: 
		player._set_key(5, (data.lipstick_color-1)*8)
