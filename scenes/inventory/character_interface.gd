extends Control

var data
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
	# load weapon
	if PlayerData.equipment_data["Item"] != null:
		var weapon = find_node("WeaponBox")
		var item_name = GameData.item_data[str(PlayerData.equipment_data["Item"])]["Name"]
		var icon_texture = load("res://Assets/Icon_Items/" + item_name + ".png")
		weapon.get_node("Icon").set_texture(icon_texture)
	# stat values
	find_node("Inventory").get_child(0).find_node("Button").visible = false
	find_node("Health").set_text(tr("HEALTH") + ": " + str(Utils.get_current_player().get_max_health()))
	find_node("Damage").set_text(tr("ATTACK") + ": " + str(Utils.get_current_player().get_attack()))
	
	data = Utils.get_current_player().get_data()
	for child in find_node("Player").get_children():
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
	load_character()


func load_character():
	var player = find_node("Player")
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
	var player = find_node("Player")
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

# Close the inventory
func _on_Button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			Utils.get_scene_manager().get_child(3).get_node("CharacterInterface").queue_free()
			Utils.get_current_player().set_player_can_interact(true)
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			PlayerData.inv_data["Weapon"] = PlayerData.equipment_data
			PlayerData.save_inventory()
