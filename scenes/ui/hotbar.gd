extends Control

onready var item_slot = get_node("Hotbar")
onready var time_label = get_node("Hotbar/TextureProgress/Time")
onready var cooldown_texture = get_node("Hotbar/TextureProgress")
var disabled = false
var type
var timer1 = false
var timer2 = false

func _ready():
	time_label.hide()
	$Hotbar/Timer.wait_time = Constants.HEALTH_COOLDOWN
	$Hotbar/Timer2.wait_time = Constants.STAMINA_POTION_COOLDOWN
	cooldown_texture.value = 0
	load_hotbar()
	$Hotbar/Timer.set_one_shot(true)
	$Hotbar/Timer2.set_one_shot(true)
	

# (re)load hotbar item and stack
func load_hotbar():
	if PlayerData.equipment_data["Hotbar"]["Item"] != null:
		var texture = GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])]["Texture"]
		var frame = GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])]["Frame"]
		var icon_texture = load("res://Assets/Icon_Items/" + texture + ".png")
		if texture == "item_icons_1":
			item_slot.get_node("Icon/Sprite").set_scale(Vector2(2,2))
			item_slot.get_node("Icon/Sprite").set_hframes(16)
			item_slot.get_node("Icon/Sprite").set_vframes(27)
		else:
			item_slot.get_node("Icon/Sprite").set_scale(Vector2(4,4))
			item_slot.get_node("Icon/Sprite").set_hframes(13)
			item_slot.get_node("Icon/Sprite").set_vframes(15)
		item_slot.get_node("Icon/Sprite").set_texture(icon_texture)
		item_slot.get_node("Icon/Sprite").frame = frame
		update_label()
		if (PlayerData.equipment_data["Hotbar"]["Item"] != null and
		 GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])].has("Stamina")):
			type = "Stamina"
			if $Hotbar/Timer2.time_left != 0:
				cooldown_texture.show()
				time_label.show()
			else:
				cooldown_texture.hide()
				time_label.hide()
				disabled = false
		elif PlayerData.equipment_data["Hotbar"]["Item"] != null:
			type = "Health"
			if $Hotbar/Timer.time_left != 0:
				cooldown_texture.show()
				time_label.show()
			else:
				cooldown_texture.hide()
				time_label.hide()
				disabled = false
	else:
		item_slot.get_node("TextureRect/Stack").set_text("")
		item_slot.get_node("TextureRect").visible = false
		item_slot.get_node("Icon/Sprite").set_texture(null)
		type = ""
		cooldown_texture.hide()
		time_label.hide()


# Update cooldown label
func _process(_delta):
	if timer1:
		Utils.get_current_player().set_health_cooldown($Hotbar/Timer.time_left)
		if Utils.get_current_player().health_cooldown == null:
			Utils.get_current_player().set_health_cooldown(0)
	if timer2:
		Utils.get_current_player().set_stamina_cooldown($Hotbar/Timer2.time_left)
		if Utils.get_current_player().stamina_cooldown == null:
			Utils.get_current_player().set_stamina_cooldown(0)
	if type == "Stamina":
		time_label.text = "%2.1f" % $Hotbar/Timer2.time_left
		cooldown_texture.value = int(($Hotbar/Timer2.time_left / Constants.STAMINA_POTION_COOLDOWN) * 100)
	if type == "Health":
		time_label.text = "%2.1f" % $Hotbar/Timer.time_left
		cooldown_texture.value = int(($Hotbar/Timer.time_left / Constants.HEALTH_COOLDOWN) * 100)


func _on_Timer_timeout():
	if type == "Health":
		cooldown_texture.value = 0
		disabled = false
		time_label.hide()
	timer1 = false
	Utils.get_current_player().set_health_cooldown(0)


# updates the label from the hotbar slot
func update_label():
	var item_stack = PlayerData.equipment_data["Hotbar"]["Stack"]
	if item_stack == null:
		item_slot.get_node("Icon/Sprite").set_texture(null)
		item_slot.get_node("TextureRect/Stack").set_text("")
		item_slot.get_node("TextureRect").visible = false
		cooldown_texture.hide()
		time_label.hide()
	elif item_stack > 1:
		item_slot.get_node("TextureRect/Stack").set_text(str(item_stack))
		item_slot.get_node("TextureRect").visible = true
	else:
		item_slot.get_node("TextureRect/Stack").set_text("")
		item_slot.get_node("TextureRect").visible = false


# Use Hotbar item
func _on_Hotbar_gui_input(event):
	if event.is_action_pressed("hotbar") or (event is InputEventMouseButton and event.pressed):
		use_item()


# Use the item
func use_item():
	if PlayerData.equipment_data["Hotbar"]["Item"] != null and !disabled and Utils.get_current_player() != null:
		if PlayerData.equipment_data["Hotbar"]["Stack"] != null:
			PlayerData.equipment_data["Hotbar"]["Stack"] -= 1
			var cooldown
			if GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])].has("Stamina"):
				Utils.get_current_player().set_stamina(Utils.get_current_player().player_stamina + 
				GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])]["Stamina"])
				type = "Stamina"
				cooldown = Constants.STAMINA_POTION_COOLDOWN
				Utils.get_current_player().set_stamina_cooldown(cooldown)
				set_cooldown_stamina(cooldown, type)
			else:
				Utils.get_current_player().set_current_health(int(Utils.get_current_player().get_current_health()) + 
				int(GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])]["Health"]))
				type = "Health"
				cooldown = Constants.HEALTH_COOLDOWN
				Utils.get_current_player().set_health_cooldown(cooldown)
				set_cooldown_health(cooldown, type)
			if PlayerData.equipment_data["Hotbar"]["Stack"] <= 0:
				PlayerData.equipment_data["Hotbar"]["Stack"] = null
				PlayerData.equipment_data["Hotbar"]["Item"] = null
				item_slot.get_node("TextureRect/Stack").set_text("")
				item_slot.get_node("TextureRect").visible = false
				item_slot.get_node("Icon/Sprite").set_texture(null)
				cooldown_texture.hide()
				time_label.hide()
			elif PlayerData.equipment_data["Hotbar"]["Stack"] == 1:
				item_slot.get_node("TextureRect/Stack").set_text("")
				item_slot.get_node("TextureRect").visible = false
			else:
				item_slot.get_node("TextureRect/Stack").set_text(str(PlayerData.equipment_data["Hotbar"]["Stack"]))
			PlayerData.inv_data["Hotbar"] = PlayerData.equipment_data["Hotbar"]
			var item_stack = PlayerData.equipment_data["Hotbar"]["Stack"]
			var hotbar_slot = Utils.get_character_interface()
			if hotbar_slot != null:
				hotbar_slot.find_node("Inventory").set_cooldown(cooldown, type)
				hotbar_slot = hotbar_slot.find_node("Hotbar")
				if item_stack == null:
					hotbar_slot.get_node("Icon/Sprite").set_texture(null)
					hotbar_slot.get_node("Icon/TextureRect/Stack").set_text("")
					hotbar_slot.get_node("Icon/TextureRect").visible = false
				elif item_stack > 1:
					hotbar_slot.get_node("Icon/TextureRect/Stack").set_text(str(item_stack))
					hotbar_slot.get_node("Icon/TextureRect").visible = true
					hotbar_slot.get_node("Icon").set_cooldown(cooldown, type)
				else:
					hotbar_slot.get_node("Icon/TextureRect/Stack").set_text("")
					hotbar_slot.get_node("Icon/TextureRect").visible = false
					hotbar_slot.get_node("Icon").set_cooldown(cooldown, type)


# starts cooldown
func set_cooldown_health(cooldown, new_type):
	if new_type == "Stamina" or new_type == "Health":
		type = new_type
	$Hotbar/Timer.wait_time = cooldown
	$Hotbar/Timer.start()
	if type == "Health":
		cooldown_texture.show()
		disabled = true
		time_label.show()
	timer1 = true
	


# Method to track second cooldown time
func set_cooldown_stamina(cooldown, new_type):
	if new_type == "Stamina" or new_type == "Health":
		type = new_type
	$Hotbar/Timer2.wait_time = cooldown
	$Hotbar/Timer2.start()
	if type == "Stamina":
		cooldown_texture.show()
		disabled = true
		time_label.show()
	timer2 = true
	


func _on_Timer2_timeout():
	if type == "Stamina":
		cooldown_texture.value = 0
		disabled = false
		time_label.hide()
	timer2 = false
	Utils.get_current_player().set_stamina_cooldown(0)


func save_and_stop_timer():
	# save player data
	Utils.save_game()
	# stop timer
	get_node("Hotbar/Timer").stop()
	_on_Timer_timeout()
	get_node("Hotbar/Timer2").stop()
	_on_Timer2_timeout()


func resume_cooldown():
	get_node("Hotbar/Timer").paused = false
	get_node("Hotbar/Timer2").paused = false


func pause_cooldown():
	get_node("Hotbar/Timer").paused = true
	get_node("Hotbar/Timer2").paused = true
