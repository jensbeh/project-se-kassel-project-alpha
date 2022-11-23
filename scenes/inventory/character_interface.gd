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
			var icon_texture = load("res://assets/icon_items/" + texture + ".png")
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
				var health_cooldown = Utils.get_current_player().health_cooldown
				var stamina_cooldown = Utils.get_current_player().stamina_cooldown
				if (PlayerData.equipment_data["Hotbar"]["Item"] != null and
				GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])].has("Stamina")):
					if stamina_cooldown != 0 and stamina_cooldown != null:
						item_slot.get_node("Icon").set_cooldown(stamina_cooldown, "Stamina")
				elif PlayerData.equipment_data["Hotbar"]["Item"] != null:
					if health_cooldown != 0 and health_cooldown != null:
						item_slot.get_node("Icon").set_cooldown(health_cooldown, "Health")
				
					
					
	# stat values
	find_node("Health").set_text(tr("HEALTH") + ": " + str(Utils.get_current_player().get_max_health()))
	if PlayerData.equipment_data["Weapon"]["Item"] != null:
		find_node("Damage").set_text(tr("ATTACK") + ": " + str(GameData.item_data[str(PlayerData.equipment_data["Weapon"]["Item"])]["Attack"]))
	else:
		find_node("Damage").set_text(tr("ATTACK") + ": " + str(0))
	find_node("Attack-Speed").set_text(tr("ATTACK-SPEED") + ": " + str(Utils.get_current_player().get_attack_speed()))
	find_node("Knockback").set_text(tr("KNOCKBACK") + ": " + str(Utils.get_current_player().get_knockback()))
	find_node("CharacterLevel").set_text(tr("LEVEL") + ".: " + str(Utils.get_current_player().get_level()))
	find_node("LightRadius").set_text(tr("LIGHT") + ": " + str(Utils.get_current_player().get_light_radius()))
	find_node("Stamina").set_text(tr("STAMINA") + ": " + str(Utils.get_current_player().get_max_stamina()))
	
	data = Utils.get_current_player().get_data()
	# Set name
	find_node("CharacterName").set_text(data.name)
	# Set stamina
	find_node("Player").max_stamina = data.maxStamina
	find_node("Player").player_stamina = data.maxStamina
	# Set preview state
	find_node("Player").preview = true
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
			Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI)
			Utils.get_character_interface().queue_free()
			Utils.get_current_player().set_player_can_interact(true)
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			PlayerData.inv_data["Weapon"] = PlayerData.equipment_data["Weapon"]
			PlayerData.inv_data["Light"] = PlayerData.equipment_data["Light"]
			PlayerData.inv_data["Hotbar"] = PlayerData.equipment_data["Hotbar"]
			Utils.save_game(true)
