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
	# load weapon, light and hotbar
	for item in ["Weapon", "Light", "Hotbar"]:
		if PlayerData.equipment_data[item]["Item"] != null:
			var item_slot = find_node(item)
			var texture = GameData.item_data[str(PlayerData.equipment_data[item]["Item"])]["Texture"]
			var frame = GameData.item_data[str(PlayerData.equipment_data[item]["Item"])]["Frame"]
			var icon_texture = load("res://Assets/Icon_Items/" + texture + ".png")
			if texture == "item_icons_1":
				item_slot.get_node("Icon/Sprite").set_scale(Vector2(2.5,2.5))
				item_slot.get_node("Icon/Sprite").set_hframes(16)
				item_slot.get_node("Icon/Sprite").set_vframes(27)
			else:
				item_slot.get_node("Icon/Sprite").set_scale(Vector2(4.5,4.5))
				item_slot.get_node("Icon/Sprite").set_hframes(13)
				item_slot.get_node("Icon/Sprite").set_vframes(15)
			item_slot.get_node("Icon/Sprite").set_texture(icon_texture)
			item_slot.get_node("Icon/Sprite").frame = frame
			if item == "Hotbar":
				var item_stack = PlayerData.equipment_data[item]["Stack"]
				if item_stack != null and item_stack > 1:
					item_slot.get_node("Icon/TextureRect/Stack").set_text(str(item_stack))
					item_slot.get_node("Icon/TextureRect").visible = true
				var cooldown = Utils.get_scene_manager().get_node("UI/PlayerUI").get_node("Hotbar/Hotbar").get_node("Timer").time_left
				if cooldown != 0 and !Utils.get_scene_manager().get_node("UI/PlayerUI").get_node("Hotbar/Hotbar").get_node("Timer").is_stopped():
					item_slot.get_node("Icon").set_cooldown(cooldown)
					
	# stat values
	find_node("Inventory").get_child(0).find_node("Button").visible = false
	find_node("Health").set_text(tr("HEALTH") + ": " + str(Utils.get_current_player().get_max_health()))
	find_node("Damage").set_text(tr("ATTACK") + ": " + str(GameData.item_data[str(PlayerData.equipment_data["Weapon"]["Item"])]["Attack"]))
	find_node("Attack-Speed").set_text(tr("ATTACK-SPEED") + ": " + str(Utils.get_current_player().get_attack_speed()))
	find_node("Knockback").set_text(tr("KNOCKBACK") + ": " + str(Utils.get_current_player().get_knockback()))
	find_node("CharacterLevel").set_text(tr("LEVEL") + ".: " + str(Utils.get_current_player().get_level()))
	find_node("LightRadius").set_text(tr("LIGHT") + ": " + str(Utils.get_current_player().get_light_radius()))
	
	data = Utils.get_current_player().get_data()
	find_node("CharacterName").set_text(data.name)
	
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
	find_node("Player").set_preview(true)
	find_node("Player").set_dragging(true)

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
			Utils.get_scene_manager().get_UI().get_node("CharacterInterface").queue_free()
			Utils.get_current_player().set_player_can_interact(true)
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			PlayerData.inv_data["Weapon"] = PlayerData.equipment_data["Weapon"]
			PlayerData.inv_data["Light"] = PlayerData.equipment_data["Light"]
			PlayerData.inv_data["Hotbar"] = PlayerData.equipment_data["Hotbar"]
			PlayerData.save_inventory()
			Utils.get_current_player().save_player_data(Utils.get_current_player().get_data())
