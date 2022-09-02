extends TextureRect

var item_slot = self

func _ready():
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
	else:
		item_slot.get_node("TextureRect/Stack").set_text(str(0))
		item_slot.get_node("TextureRect").visible = false
		item_slot.get_node("Icon/Sprite").set_texture(null)


func update_label():
	var item_stack = PlayerData.equipment_data["Hotbar"]["Stack"]
	if item_stack != null and item_stack > 1:
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
	if PlayerData.equipment_data["Hotbar"]["Item"] != null:
		if PlayerData.equipment_data["Hotbar"]["Stack"] != null:
			PlayerData.equipment_data["Hotbar"]["Stack"] -= 1
			Utils.get_current_player().set_current_health(int(Utils.get_current_player().get_current_health()) + 
			int(GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])]["Health"]))
			if PlayerData.equipment_data["Hotbar"]["Stack"] <= 0:
				PlayerData.equipment_data["Hotbar"]["Stack"] = null
				PlayerData.equipment_data["Hotbar"]["Item"] = null
				item_slot.get_node("TextureRect/Stack").set_text("0")
				item_slot.get_node("TextureRect").visible = false
				item_slot.get_node("Icon/Sprite").set_texture(null)
			elif PlayerData.equipment_data["Hotbar"]["Stack"] == 1:
				item_slot.get_node("TextureRect/Stack").set_text("1")
				item_slot.get_node("TextureRect").visible = false
			else:
				item_slot.get_node("TextureRect/Stack").set_text(str(PlayerData.equipment_data["Hotbar"]["Stack"]))
			PlayerData.inv_data["Hotbar"] = PlayerData.equipment_data["Hotbar"]
			var item_stack = PlayerData.equipment_data["Hotbar"]["Stack"]
			var hotbar_slot = Utils.get_scene_manager().get_node("UI").get_node_or_null("CharacterInterface").find_node("Hotbar")
			if hotbar_slot != null:
				if item_stack != null and item_stack > 1:
					hotbar_slot.get_node("Icon/TextureRect/Stack").set_text(str(item_stack))
					hotbar_slot.get_node("Icon/TextureRect").visible = true
				else:
					hotbar_slot.get_node("Icon/TextureRect/Stack").set_text("")
					hotbar_slot.get_node("Icon/TextureRect").visible = false
