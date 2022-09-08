extends Control

onready var item_slot = get_node("Hotbar")
onready var time_label = get_node("Hotbar/TextureProgress/Time")
onready var cooldown_texture = get_node("Hotbar/TextureProgress")
var disabled = false

func _ready():
	time_label.hide()
	$Hotbar/Timer.wait_time = Constants.COOLDOWN
	cooldown_texture.value = 0
	set_process(false)
	load_hotbar()
	$Hotbar/Timer.set_one_shot(true)
	

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
		if cooldown_texture.value != 0:
			cooldown_texture.show()
			time_label.show()
		else:
			cooldown_texture.hide()
			time_label.hide()
	else:
		item_slot.get_node("TextureRect/Stack").set_text("")
		item_slot.get_node("TextureRect").visible = false
		item_slot.get_node("Icon/Sprite").set_texture(null)
		
		cooldown_texture.hide()
		time_label.hide()


func _process(_delta):
	time_label.text = "%2.1f" % $Hotbar/Timer.time_left
	cooldown_texture.value = int(($Hotbar/Timer.time_left / Constants.COOLDOWN) * 100)


func _on_Timer_timeout():
	cooldown_texture.value = 0
	disabled = false
	time_label.hide()
	set_process(false)


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
	if PlayerData.equipment_data["Hotbar"]["Item"] != null and !disabled:
		if PlayerData.equipment_data["Hotbar"]["Stack"] != null:
			PlayerData.equipment_data["Hotbar"]["Stack"] -= 1
			Utils.get_current_player().set_current_health(int(Utils.get_current_player().get_current_health()) + 
			int(GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])]["Health"]))
			set_cooldown(Constants.COOLDOWN)
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
			var hotbar_slot = Utils.get_scene_manager().get_node("UI").get_node_or_null("CharacterInterface")
			if hotbar_slot != null:
				hotbar_slot.find_node("Inventory").set_cooldown(Constants.COOLDOWN)
				hotbar_slot = hotbar_slot.find_node("Hotbar")
				if item_stack == null:
					hotbar_slot.get_node("Icon/Sprite").set_texture(null)
					hotbar_slot.get_node("Icon/TextureRect/Stack").set_text("")
					hotbar_slot.get_node("Icon/TextureRect").visible = false
				elif item_stack > 1:
					hotbar_slot.get_node("Icon/TextureRect/Stack").set_text(str(item_stack))
					hotbar_slot.get_node("Icon/TextureRect").visible = true
					hotbar_slot.get_node("Icon").set_cooldown(Constants.COOLDOWN)
				else:
					hotbar_slot.get_node("Icon/TextureRect/Stack").set_text("")
					hotbar_slot.get_node("Icon/TextureRect").visible = false
					hotbar_slot.get_node("Icon").set_cooldown(Constants.COOLDOWN)


# starts cooldown
func set_cooldown(cooldown):
	$Hotbar/Timer.wait_time = cooldown
	cooldown_texture.show()
	$Hotbar/Timer.start()
	disabled = true
	set_process(true)
	time_label.show()

