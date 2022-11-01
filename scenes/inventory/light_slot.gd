extends TextureRect

var tool_tip = load(Constants.TOOLTIP)


# Get information about drag item
func get_drag_data(_pos):
	var slot = get_parent().get_name()
	if PlayerData.equipment_data[slot]["Item"] != null:
		Utils.get_current_player().set_dragging(true)
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = "CharacterInterface"
		data["origin_item_id"] = PlayerData.equipment_data[slot]["Item"]
		data["origin_slot"] = GameData.item_data[str(PlayerData.equipment_data[slot]["Item"])]
		data["origin_texture"] = get_child(0).texture
		data["origin_frame"] = get_child(0).frame
		data["origin_stackable"] = false
		data["origin_stack"] = 1
		
		# Texture wich will drag
		var drag_texture = Sprite.new()
		if GameData.item_data[str(PlayerData.equipment_data[slot]["Item"])]["Texture"] == "item_icons_1":
			drag_texture.set_scale(Vector2(2.5,2.5))
			drag_texture.set_hframes(16)
			drag_texture.set_vframes(27)
			drag_texture.texture = get_child(0).texture
			drag_texture.frame = get_child(0).frame
		else:
			drag_texture.set_scale(Vector2(4.5,4.5))
			drag_texture.set_hframes(13)
			drag_texture.set_vframes(15)
			drag_texture.texture = get_child(0).texture
			drag_texture.frame = get_child(0).frame
		
		# Pos on mouse while drag
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.position = -0.5 * drag_texture.scale
		set_drag_preview(control)
		
		return data


# Check if we can drop an item to this slot
func can_drop_data(_pos, data):
	var target_slot = get_parent().get_name()
	# Move item
	if GameData.item_data[str(data["origin_item_id"])]["Category"] == "Light":
		if PlayerData.equipment_data[target_slot]["Item"] == null:
			data["target_item_id"] = null
			data["target_texture"] = null
			data["target_stack"] = null
			data["target_frame"] = null
			return true
		# Swap item
		else:
			data["target_item_id"] = PlayerData.equipment_data[target_slot]["Item"]
			data["target_texture"] = get_child(0).texture
			data["target_frame"] = get_child(0).frame
			data["target_stack"] = PlayerData.equipment_data[target_slot]["Stack"]
			return true
	else:
		return false


func drop_data(_pos, data):
	var target_slot = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	if data["origin_node"] == self:
		pass
	else:
		# Update the data of the origin
		if data["origin_panel"] == "Inventory":
			PlayerData.inv_data[origin_slot]["Item"] = data["target_item_id"]
			PlayerData.inv_data[origin_slot]["Stack"] = data["target_stack"]
		elif data["origin_panel"] == "Delete":
			data["origin_node"].item = PlayerData.inv_data[target_slot]["Item"]
			data["origin_node"].stack = PlayerData.inv_data[target_slot]["Stack"]
		
		# Update the texture and label of the origin
		if data["origin_panel"] == "Inventory" and data["target_item_id"] == null:
			data["origin_node"].get_child(0).texture = null
			data["origin_node"].get_node("../TextureRect/Stack").set_text("")
		else:
			data["origin_node"].get_child(0).texture = data["target_texture"]
			if data["target_frame"] != null:
				data["origin_node"].get_child(0).frame = data["target_frame"]
			verify_origin_texture(data)
			if data["target_stack"] != null and data["target_stack"] > 1:
				data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["target_stack"]))
			
		# Update the texture, label and data of the target
		PlayerData.equipment_data[target_slot]["Item"] = data["origin_item_id"]
		get_child(0).texture = data["origin_texture"]
		get_child(0).frame = data["origin_frame"]
		verify_target_texture(data)
		PlayerData.equipment_data[target_slot]["Stack"] = data["origin_stack"]
		
		var light_value = GameData.item_data[str(PlayerData.equipment_data[target_slot]["Item"])]["Radius"]
		get_parent().get_parent().get_parent().get_parent().get_parent().find_node("LightRadius").set_text(tr("LIGHT") + ": " + str(light_value))
		Utils.get_current_player().set_light(light_value)
	
	Utils.get_current_player().set_dragging(false)


func verify_origin_texture(data):
	if data["target_item_id"] != null:
		if data["origin_panel"] == "TradeInventory" or data["origin_panel"] == "Inventory":
			if GameData.item_data[str(data["target_item_id"])]["Texture"] == "item_icons_1":
				data["origin_node"].get_child(0).set_scale(Vector2(1.5,1.5))
				data["origin_node"].get_child(0).set_hframes(16)
				data["origin_node"].get_child(0).set_vframes(27)
			else:
				data["origin_node"].get_child(0).set_scale(Vector2(2.5,2.5))
				data["origin_node"].get_child(0).set_hframes(13)
				data["origin_node"].get_child(0).set_vframes(15)
		elif data["origin_panel"] == "Delete":
			if GameData.item_data[str(data["target_item_id"])]["Texture"] == "item_icons_1":
				data["origin_node"].get_child(0).set_scale(Vector2(1,1))
				data["origin_node"].get_child(0).set_hframes(16)
				data["origin_node"].get_child(0).set_vframes(27)
			else:
				data["origin_node"].get_child(0).set_scale(Vector2(1.5,1.5))
				data["origin_node"].get_child(0).set_hframes(13)
				data["origin_node"].get_child(0).set_vframes(15)
		else:
			if GameData.item_data[str(data["target_item_id"])]["Texture"] == "item_icons_1":
				data["origin_node"].get_child(0).set_scale(Vector2(2.5,2.5))
				data["origin_node"].get_child(0).set_hframes(16)
				data["origin_node"].get_child(0).set_vframes(27)
			else:
				data["origin_node"].get_child(0).set_scale(Vector2(4.5,4.5))
				data["origin_node"].get_child(0).set_hframes(13)
				data["origin_node"].get_child(0).set_vframes(15)
	
	
func verify_target_texture(data):
	if data["origin_item_id"] != null:
		if GameData.item_data[str(data["origin_item_id"])]["Texture"] == "item_icons_1":
			get_child(0).set_scale(Vector2(2.5,2.5))
			get_child(0).set_hframes(16)
			get_child(0).set_vframes(27)
		else:
			get_child(0).set_scale(Vector2(4.5,4.5))
			get_child(0).set_hframes(13)
			get_child(0).set_vframes(15)


# ToolTips
func _on_Icon_mouse_entered():
	show_tooltip()

func _on_Icon_mouse_exited():
	hide_tooltip()


func show_tooltip():
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "CharacterInterface"
	tool_tip_instance.slot = get_parent().get_name()
	
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(64,64)
	
	add_child(tool_tip_instance)
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()

func hide_tooltip():
	get_node("ToolTip").free()
