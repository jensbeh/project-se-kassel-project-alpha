extends Node2D

const SAVE_FILE_EXTENSION = ".json"
var delete_id
var delete_container

var selected_character = 0
var style2 = StyleBoxFlat.new()
var style1 = StyleBoxFlat.new()

onready var list = $ScrollContainer2/MarginContainer/ScrollContainer/MarginContainer/CharacterList
onready var scroll = $ScrollContainer2/MarginContainer/ScrollContainer
onready var icon = preload("res://assets/deleteButtonIcon.png")

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
	get_node("Back").set_text(tr("BACK_TO_MAIN_MENU"))
	get_node("Create Character").set_text(tr("CREATE_NEW_CHARACTER"))
	
	# Create Selected Style
	style2.set_bg_color(Color(0.6, 0.6, 0.6, 1))
	style1.set_bg_color(Color(0.4, 0.4, 0.4, 1))
	style1.set_corner_radius_all(5)
	style2.set_corner_radius_all(5)
	
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
		# disabled the play and delete buttons
		for child in list.get_children():
			child.get_child(1).get_child(0).get_child(1).get_child(0).disabled = true
			child.get_child(1).get_child(0).get_child(1).get_child(1).disabled = true
		list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(0).disabled = false
		list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(1).disabled = false
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
	
	Utils.get_player().set_visibility("Shadow", true)
	call_deferred("load_character")
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()


# Method to destroy the scene
# Is called when SceneManager changes scene after loading new scene
func destroy_scene():
	pass


# loaded the player data
func load_data():
	var dir = Directory.new()
	dir.open(Constants.SAVE_CHARACTER_PATH)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif !file.begins_with("."):
			var save_path = Directory.new()
			save_path.open(Constants.SAVE_CHARACTER_PATH + file)
			save_path.list_dir_begin()
			while true:
				var data_file = save_path.get_next()
				if data_file == "":
					break
				elif data_file.ends_with(".json") and !"inv_data" in data_file.get_basename() and !file.begins_with("."):
					data_file.get_file()
					var save_game = File.new()
					save_game.open(Constants.SAVE_CHARACTER_PATH + file + "/" + data_file, File.READ)
					var save_game_data = {}
					save_game_data = parse_json(save_game.get_line())
					save_game.close()
					data_list.append(save_game_data)
					var name = save_game_data.name
					var gold = save_game_data.gold
					var level = save_game_data.level
					var character_id = save_game_data.id
					create_item(name, level, gold, character_id)
			save_path.list_dir_end()
	dir.list_dir_end()


# click for delete this character
func on_delete_click(id, container):
	find_node("ConfirmationDialog").set_text(" " + tr("DELETECHARAC") + " " + "\n" + " \"" + data_list[selected_character].name + "\" ? ")
	var styleup1 = StyleBoxFlat.new()
	styleup1.set_bg_color(Color(1, 0, 0))
	styleup1.set_corner_radius_all(5)
	var hover = StyleBoxFlat.new()
	hover.set_bg_color(Color(0.956863, 0.25098, 0.25098))
	hover.set_corner_radius_all(5)
	hover.set_expand_margin_all(3)
	var pressed = StyleBoxFlat.new()
	pressed.set_bg_color(Color(0.722656, 0.03952, 0.03952))
	pressed.set_corner_radius_all(5)
	pressed.set_expand_margin_all(3)
	var styleup2 = StyleBoxFlat.new()
	styleup2.set_corner_radius_all(5)
	styleup2.set_bg_color(Color(0.6, 0.6, 0.6))
	find_node("ConfirmationDialog").get_cancel().add_stylebox_override("normal", styleup2)
	find_node("ConfirmationDialog").get_ok().add_stylebox_override("normal", styleup1)
	find_node("ConfirmationDialog").get_ok().add_stylebox_override("hover", hover)
	find_node("ConfirmationDialog").get_ok().add_stylebox_override("pressed", pressed)
	find_node("ConfirmationDialog").get_cancel().set_text(tr("CANCLE"))
	
	find_node("ConfirmationDialog").get_ok().set_text(tr("DELETE"))
	
	find_node("ConfirmationDialog").popup()
	delete_id = id
	delete_container = container


func delete_character():
	var dir = Directory.new()
	var name = data_list[selected_character].name
	if dir.file_exists(Constants.SAVE_CHARACTER_PATH + delete_id + "/" + name + SAVE_FILE_EXTENSION):
		dir.remove(Constants.SAVE_CHARACTER_PATH + delete_id + "/" + name + SAVE_FILE_EXTENSION)
	# remove inventory data
	if dir.dir_exists(Constants.SAVE_CHARACTER_PATH + delete_id + "/"):
		for i in ["bella", "heinz", "lea", "sam", delete_id]:
			dir.remove(Constants.SAVE_CHARACTER_PATH + delete_id + "/merchant/" + i + "_inv_data" + SAVE_FILE_EXTENSION)
		dir.remove(Constants.SAVE_CHARACTER_PATH + delete_id + "/merchant/")
		dir.remove(Constants.SAVE_CHARACTER_PATH + delete_id + "/" + name + "_inv_data" + SAVE_FILE_EXTENSION)
		dir.remove(Constants.SAVE_CHARACTER_PATH + delete_id + "/")
	list.remove_child(delete_container)
	data_list.remove(selected_character)
	if list.get_child_count() != 0:
		if selected_character != 0: 
			selected_character -= 1
		load_character()
		change_menu_color()
		for child in list.get_children():
			child.get_child(1).get_child(0).get_child(1).get_child(0).disabled = true
			child.get_child(1).get_child(0).get_child(1).get_child(1).disabled = true
		list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(0).disabled = false
		list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(1).disabled = false
	else:
		selected_character = 0
		Utils.get_player().visible = false
	delete_id = null
	delete_container = null


# click on play button to enter camp
func on_play_click():
	start_game()


# create Character Item to Choose
func create_item(charac_name, charac_level, charac_gold, character_id):
	var container = MarginContainer.new()
	var panel = Panel.new()
	var delete_button = Button.new()
	var play_button = Button.new()
	play_button.set_text(" ➤ ")
	delete_button.connect("pressed", self, "on_delete_click", [character_id, container])
	play_button.connect("pressed", self, "on_play_click")
	panel.add_stylebox_override("panel", style2)
	container.add_child(panel)
	var mcontainer = MarginContainer.new()
	mcontainer.add_constant_override("margin_top", 10)
	mcontainer.add_constant_override("margin_left", 10)
	mcontainer.add_constant_override("margin_bottom", 10)
	mcontainer.add_constant_override("margin_right", 10)
	var vbox = VBoxContainer.new()
	var hboxc = HBoxContainer.new()
	hboxc.add_constant_override("separation", 50)
	vbox.add_constant_override("separation", 10)
	vbox.set_h_size_flags(3)
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
	gold.set_text("Gold: " + str(charac_gold))
	gold.add_font_override("font", font)
	hbox.add_child(gold)
	var level = Label.new()
	level.set_text("Level: " + str(charac_level))
	level.add_font_override("font", font)
	hbox.add_child(level)
	vbox.add_child(hbox)
	hboxc.add_child(vbox)
	var hboxbutton = HBoxContainer.new()
	hbox.add_constant_override("separation", 30)
	hboxbutton.add_constant_override("separation", 30)
	var font1 = DynamicFont.new()
	font1.font_data = load("res://assets/Hack_Regular.ttf")
	font1.set_size(38)
	font1.set_outline_color(0xffffff)
	play_button.add_font_override("font", font1)
	delete_button.icon = icon
	hboxbutton.add_child(play_button)
	hboxbutton.add_child(delete_button)
	hboxc.add_child(hboxbutton)
	mcontainer.add_child(hboxc)
	mcontainer.set_script(load(Constants.CHARACTER_SCREEN_CONTAINER_SCRIPT_PATH))
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
	var transition_data = TransitionData.Menu.new(Constants.MAIN_MENU_PATH)
	Utils.get_scene_manager().transition_to_scene(transition_data)


func _on_Create_Character_pressed():
	var transition_data = TransitionData.Menu.new(Constants.CREATE_CHARACTER_SCREEN_PATH)
	Utils.get_scene_manager().transition_to_scene(transition_data)


func _input(_event):
	if Input.is_action_just_pressed("ui_down"):
		unchange_menu_color()
		if selected_character < list.get_child_count()-1:
			selected_character = selected_character + 1
			list.get_child(selected_character).grab_focus()
			load_character()
			for child in list.get_children():
				child.get_child(1).get_child(0).get_child(1).get_child(0).disabled = true
				child.get_child(1).get_child(0).get_child(1).get_child(1).disabled = true
			list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(0).disabled = false
			list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(1).disabled = false
		change_menu_color()
	elif Input.is_action_just_pressed("ui_up"):
		unchange_menu_color()
		if selected_character > 0:
			selected_character = selected_character - 1
			list.get_child(selected_character).grab_focus()
			load_character()
			for child in list.get_children():
				child.get_child(1).get_child(0).get_child(1).get_child(0).disabled = true
				child.get_child(1).get_child(0).get_child(1).get_child(1).disabled = true
			list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(0).disabled = false
			list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(1).disabled = false
		change_menu_color()
	elif Input.is_action_just_pressed("enter"):
		start_game()


func on_click(id):
	for item in list.get_children():
		if item.get_child(1).get_instance_id() == id:
			unchange_menu_color()
			selected_character = item.get_index()
			for child in list.get_children():
				child.get_child(1).get_child(0).get_child(1).get_child(0).disabled = true
				child.get_child(1).get_child(0).get_child(1).get_child(1).disabled = true
			list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(0).disabled = false
			list.get_child(selected_character).get_child(1).get_child(0).get_child(1).get_child(1).disabled = false
			load_character()


func on_double_click():
	start_game()


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
	# set the IDLE/WALK animation colors
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
	
	
	# set the ATTACK animation colors
	# Shoes
	player.reset_attack_key("Shoes:frame")
	player._set_attack_key("Shoes:frame", data.shoe_color * 8)
	# Pants
	player.reset_attack_key("Pants:frame")
	player._set_attack_key("Pants:frame", data.legs_color * 8)
	# Clothes
	player.reset_attack_key("Clothes:frame")
	player._set_attack_key("Clothes:frame", data.torso_color * 8)
	# Blush
	player.reset_attack_key("Blush:frame")
	if data.blush_color == 0:
		player._set_attack_key("Blush:frame", data.blush_color * 8)
	else: 
		player._set_attack_key("Blush:frame", (data.blush_color - 1) * 8)
	# Lipstick
	player.reset_attack_key("Lipstick:frame")
	if data.lipstick_color == 0:
		player._set_attack_key("Lipstick:frame", data.lipstick_color * 8)
	else: 
		player._set_attack_key("Lipstick:frame", (data.lipstick_color - 1) * 8)
	# Beard
	player.reset_attack_key("Beard:frame")
	if data.beard_color == 0:
		player._set_attack_key("Beard:frame", data.beard_color * 8)
	else: 
		player._set_attack_key("Beard:frame", (data.beard_color - 1) * 8)
	# Eyes
	player.reset_attack_key("Eyes:frame")
	player._set_attack_key("Eyes:frame", data.eyes_color * 8)
	# Hairs
	player.reset_attack_key("Hair:frame")
	player._set_attack_key("Hair:frame", data.hair_color * 8)
	
	
	# set the HURT animation colors
	# Shoes
	player.reset_hurt_key("Shoes:frame")
	player._set_hurt_key("Shoes:frame", data.shoe_color * 8)
	# Pants
	player.reset_hurt_key("Pants:frame")
	player._set_hurt_key("Pants:frame", data.legs_color * 8)
	# Clothes
	player.reset_hurt_key("Clothes:frame")
	player._set_hurt_key("Clothes:frame", data.torso_color * 8)
	# Blush
	player.reset_hurt_key("Blush:frame")
	if data.blush_color == 0:
		player._set_hurt_key("Blush:frame", data.blush_color * 8)
	else: 
		player._set_hurt_key("Blush:frame", (data.blush_color - 1) * 8)
	# Lipstick
	player.reset_hurt_key("Lipstick:frame")
	if data.lipstick_color == 0:
		player._set_hurt_key("Lipstick:frame", data.lipstick_color * 8)
	else: 
		player._set_hurt_key("Lipstick:frame", (data.lipstick_color - 1) * 8)
	# Beard
	player.reset_hurt_key("Beard:frame")
	if data.beard_color == 0:
		player._set_hurt_key("Beard:frame", data.beard_color * 8)
	else: 
		player._set_hurt_key("Beard:frame", (data.beard_color - 1) * 8)
	# Eyes
	player.reset_hurt_key("Eyes:frame")
	player._set_hurt_key("Eyes:frame", data.eyes_color * 8)
	# Hairs
	player.reset_hurt_key("Hair:frame")
	player._set_hurt_key("Hair:frame", data.hair_color * 8)
	
	
	# set the DIE animation colors
	# Shoes
	player.reset_die_key("Shoes:frame")
	player._set_die_key("Shoes:frame", data.shoe_color * 8)
	# Pants
	player.reset_die_key("Pants:frame")
	player._set_die_key("Pants:frame", data.legs_color * 8)
	# Clothes
	player.reset_die_key("Clothes:frame")
	player._set_die_key("Clothes:frame", data.torso_color * 8)
	# Blush
	player.reset_die_key("Blush:frame")
	if data.blush_color == 0:
		player._set_die_key("Blush:frame", data.blush_color * 8)
	else: 
		player._set_die_key("Blush:frame", (data.blush_color - 1) * 8)
	# Lipstick
	player.reset_die_key("Lipstick:frame")
	if data.lipstick_color == 0:
		player._set_die_key("Lipstick:frame", data.lipstick_color * 8)
	else: 
		player._set_die_key("Lipstick:frame", (data.lipstick_color - 1) * 8)
	# Beard
	player.reset_die_key("Beard:frame")
	if data.beard_color == 0:
		player._set_die_key("Beard:frame", data.beard_color * 8)
	else: 
		player._set_die_key("Beard:frame", (data.beard_color - 1) * 8)
	# Eyes
	player.reset_die_key("Eyes:frame")
	player._set_die_key("Eyes:frame", data.eyes_color * 8)
	# Hairs
	player.reset_die_key("Hair:frame")
	player._set_die_key("Hair:frame", data.hair_color * 8)
	
	# set the COLLECT animation colors
	# Shoes
	player.reset_collect_key("Shoes:frame")
	player._set_collect_key("Shoes:frame", data.shoe_color * 8)
	# Pants
	player.reset_collect_key("Pants:frame")
	player._set_collect_key("Pants:frame", data.legs_color * 8)
	# Clothes
	player.reset_collect_key("Clothes:frame")
	player._set_collect_key("Clothes:frame", data.torso_color * 8)
	# Blush
	player.reset_collect_key("Blush:frame")
	if data.blush_color == 0:
		player._set_collect_key("Blush:frame", data.blush_color * 8)
	else: 
		player._set_collect_key("Blush:frame", (data.blush_color - 1) * 8)
	# Lipstick
	player.reset_collect_key("Lipstick:frame")
	if data.lipstick_color == 0:
		player._set_collect_key("Lipstick:frame", data.lipstick_color * 8)
	else: 
		player._set_collect_key("Lipstick:frame", (data.lipstick_color - 1) * 8)
	# Beard
	player.reset_collect_key("Beard:frame")
	if data.beard_color == 0:
		player._set_collect_key("Beard:frame", data.beard_color * 8)
	else: 
		player._set_collect_key("Beard:frame", (data.beard_color - 1) * 8)
	# Eyes
	player.reset_collect_key("Eyes:frame")
	player._set_collect_key("Eyes:frame", data.eyes_color * 8)
	# Hairs
	player.reset_collect_key("Hair:frame")
	player._set_collect_key("Hair:frame", data.hair_color * 8)


# Method to start game scene
func start_game():
	# Set current player to use for other scenes
	Utils.set_current_player(Utils.get_player())
	
	# Set spawn
#	var player_position = Vector2(1128,616) # Camp
#	var player_position = Vector2(768,752) # Grassland - Dungeon1
#	var player_position = Vector2(1056,-80) # Grassland - Beach
#	var player_position = Vector2(1040, 64) # Grassland - Dungeon1/Beach
#	var player_position = Vector2(-864, -625) # Grassland - Mountain Biome Entrance
#	var player_position = Vector2(-416,-928) # Grassland - Mountain
#	var player_position = Vector2(-730,-1700) # Grassland - Top
#	var player_position = Vector2(-2080,150) # Grassland - House1
#	var player_position = Vector2(336,-62) # Dungeon1-1
#	var player_position = Vector2(432,-120) # Dungeon1-3
#	var player_position = Vector2(240,480) # Dungeon2-4
#	var player_position = Vector2(-300,64) # Dungeon3-2
#	var player_position = Vector2(-384,176) # Dungeon3-4
#	var view_direction = Vector2(0,1)
	
	# Set data
	var data = data_list[selected_character]
	Utils.get_current_player().set_data(data)
	PlayerData.set_path(data.id)
	PlayerData._ready()
	var item_id = PlayerData.equipment_data["Weapon"]["Item"]
	Utils.get_current_player().set_max_health(data.maxLP)
	Utils.get_current_player().set_weapon(item_id, data.attack, data.attack_speed, data.knockback)
	Utils.get_current_player().set_level(data.level)
	Utils.get_current_player().set_current_health(data.currentHP)
	# must call before set exp and after set lp and level
	Utils.get_player_ui().setup_ui()
	
	Utils.get_current_player().set_exp(data.exp)
	Utils.get_current_player().set_stamina(data.stamina)
	Utils.get_current_player().set_gold(data.gold)
	Utils.get_current_player().set_light(data.light)
	if data.has("has_map"):
		Utils.get_ui().has_map = data.has_map
	if data.has("show_map"):
		Utils.get_ui().show_map = data.show_map
	
	Utils.get_current_player().health_cooldown = data.cooldown
	Utils.get_current_player().stamina_cooldown = data.stamina_cooldown
	
	DayNightCycle.current_time = data.time
	
	Utils.get_hotbar().load_hotbar()
	if (PlayerData.equipment_data["Hotbar"]["Item"] != null and
	 GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])].has("Stamina")):
		if data.has("cooldown") and data.cooldown != 0:
			Utils.get_hotbar().set_cooldown_health(data.cooldown, "Stamina")
		if data.has("stamina_cooldown") and data.stamina_cooldown != 0:
			Utils.get_hotbar().set_cooldown_stamina(data.stamina_cooldown, "Stamina")
			
	elif PlayerData.equipment_data["Hotbar"]["Item"] != null:
		if data.has("stamina_cooldown") and data.stamina_cooldown != 0:
			Utils.get_hotbar().set_cooldown_stamina(data.stamina_cooldown, "Health")
		if data.has("cooldown") and data.cooldown != 0:
			Utils.get_hotbar().set_cooldown_health(data.cooldown, "Health")
	
	
	# Transition
#	var transition_data = TransitionData.GamePosition.new(Constants.CAMP_FOLDER + "/Camp.tscn", player_position, view_direction)
#	var transition_data = TransitionData.GamePosition.new(Constants.GRASSLAND_SCENE_PATH, player_position, view_direction)
#	var transition_data = TransitionData.GamePosition.new("res://scenes/dungeons/dungeon1/Dungeon1-lvl1.tscn", player_position, view_direction)
#	var transition_data = TransitionData.GamePosition.new("res://scenes/dungeons/dungeon1/Dungeon1-lvl3.tscn", player_position, view_direction)
#	var transition_data = TransitionData.GamePosition.new("res://scenes/dungeons/dungeon2/Dungeon2-lvl4.tscn", player_position, view_direction)
#	var transition_data = TransitionData.GamePosition.new("res://scenes/dungeons/dungeon3/Dungeon3-lvl2.tscn", player_position, view_direction)
#	var transition_data = TransitionData.GamePosition.new("res://scenes/dungeons/dungeon3/Dungeon3-lvl4.tscn", player_position, view_direction)
	
	# Set spawn & transition
	var transition_data = TransitionData.GamePosition.new(data.scene_transition, str2var(data.position), str2var(data.view_direction))
	
	Utils.get_scene_manager().transition_to_scene(transition_data)


func _on_ConfirmationDialog_confirmed():
	delete_character()

