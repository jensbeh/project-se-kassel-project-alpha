extends Control

var inv_slot = load(Constants.INV_SLOT)

onready var gridcontainer = get_node("Background/MarginContainer/VBox/ScrollContainer/GridContainer")

# Load player inventory
func _ready():
	for i in range(1,31):
		var inv_slot_new = inv_slot.instance()
		var slot = "Inv" + str(i)
		if PlayerData.inv_data[slot]["Item"] != null:
			var texture = GameData.item_data[str(PlayerData.inv_data[slot]["Item"])]["Texture"]
			var frame = GameData.item_data[str(PlayerData.inv_data[slot]["Item"])]["Frame"]
			var icon_texture = load("res://Assets/Icon_Items/" + texture + ".png")
			if texture == "item_icons_1":
				inv_slot_new.get_node("Icon/Sprite").set_scale(Vector2(1.5,1.5))
				inv_slot_new.get_node("Icon/Sprite").set_hframes(16)
				inv_slot_new.get_node("Icon/Sprite").set_vframes(27)
			else:
				inv_slot_new.get_node("Icon/Sprite").set_scale(Vector2(2.5,2.5))
				inv_slot_new.get_node("Icon/Sprite").set_hframes(13)
				inv_slot_new.get_node("Icon/Sprite").set_vframes(15)
			inv_slot_new.get_node("Icon/Sprite").set_texture(icon_texture)
			inv_slot_new.get_node("Icon/Sprite").frame = frame
			
			var item_stack = PlayerData.inv_data[slot]["Stack"]
			if item_stack != null and item_stack > 1:
				inv_slot_new.get_node("TextureRect/Stack").set_text(str(item_stack))
				inv_slot_new.get_node("TextureRect").visible = true
		gridcontainer.add_child(inv_slot_new, true)
	# Sets the name and the gold from the player
	$Background/MarginContainer/VBox/TitleBox/Title/Titlename.text = tr("INVENTORY")
	$Background/MarginContainer/VBox/TitleBox/Control/Gold.text = "Gold: " + str(Utils.get_current_player().get_gold())
	if Utils.get_trade_inventory() == null:
		var health_cooldown = Utils.get_current_player().health_cooldown
		var stamina_cooldown = Utils.get_current_player().stamina_cooldown
		if health_cooldown != 0 and health_cooldown != null:
			set_cooldown(health_cooldown, "Health")
		if stamina_cooldown != 0 and stamina_cooldown != null:
			set_cooldown(stamina_cooldown, "Stamina")

# Close the inventory
func _on_Button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if Utils.get_trade_inventory() != null:
				Utils.get_trade_inventory().queue_free()
				Utils.get_current_player().set_player_can_interact(true)
				Utils.get_current_player().set_movement(true)
				Utils.get_current_player().set_movment_animation(true)
				# Reset npc interaction state
				for npc in Utils.get_scene_manager().get_current_scene().find_node("npclayer").get_children():
					npc.set_interacted(false)
			else:
				Utils.get_inventory().queue_free()
			PlayerData.save_inventory()


func set_cooldown(cooldown, type):
	for i in range(1,31):
		var slot = "Inv" + str(i)
		if PlayerData.inv_data[slot]["Item"] != null:
			if GameData.item_data[str(PlayerData.inv_data[slot]["Item"])]["Category"] in ["Potion", "Food"]:
				if (GameData.item_data[str(PlayerData.inv_data[slot]["Item"])].has(type) and 
					GameData.item_data[str(PlayerData.inv_data[slot]["Item"])][type] != null):
					gridcontainer.get_child(i-1).get_node("Icon").set_cooldown(cooldown, type)
			
