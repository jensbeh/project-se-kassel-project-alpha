extends TextureRect

var item_slot = self

func _ready():
	if PlayerData.equipment_data["Hotbar"]["Item"] != null:
		var texture = GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])]["Texture"]
		var frame = GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])]["Frame"]
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
		
		var item_stack = PlayerData.equipment_data["Hotbar"]["Stack"]
		if item_stack != null and item_stack > 1:
			item_slot.get_node("TextureRect/Stack").set_text(str(item_stack))
			item_slot.get_node("TextureRect").visible = true


# Use Hotbar item
func _on_Hotbar_gui_input(event):
	if event.is_action_pressed("hotbar") or (event is InputEventMouseButton and event.pressed):
		PlayerData.equipment_data["Hotbar"]["Stack"] -= 1
		if PlayerData.equipment_data["Hotbar"]["Stack"] <= 0:
			PlayerData.equipment_data["Hotbar"]["Stack"] = null
			PlayerData.equipment_data["Hotbar"]["Item"] = null
			item_slot.get_node("TextureRect/Stack").set_text("0")
			item_slot.get_node("TextureRect").visible = false
		elif PlayerData.equipment_data["Hotbar"]["Stack"] == 1:
			item_slot.get_node("TextureRect/Stack").set_text("1")
			item_slot.get_node("TextureRect").visible = false
		else:
			item_slot.get_node("TextureRect/Stack").set_text(PlayerData.equipment_data["Hotbar"]["Stack"])
		Utils.get_current_player().set_current_health(Utils.get_current_player().get_current_health() + 
		GameData.item_data[str(PlayerData.equipment_data["Hotbar"]["Item"])]["Health"])
		PlayerData.inv_data["Hotbar"] = PlayerData.equipment_data["Hotbar"]
