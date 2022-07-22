extends TextureRect

var tool_tip = load(Constants.TOOLTIP)

# Get information about drag item
func get_drag_data(_pos):
	if PlayerData.equipment_data["Item"] != null:
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = "CharacterInterface"
		data["origin_item_id"] = PlayerData.equipment_data["Item"]
		data["origin_slot"] = GameData.item_data[str(PlayerData.equipment_data["Item"])]
		data["origin_texture"] = texture
		data["origin_stackable"] = false
		data["origin_stack"] = 1
		
		# Texture wich will drag
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = texture
		drag_texture.rect_size = Vector2(100,100)
		
		# Pos on mouse while drag
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		
		return data

# Check if we can drop an item to this slot
func can_drop_data(_pos, data):
	# Move item
	if GameData.item_data[str(data["origin_item_id"])]["Category"] == "Weapon":
		if PlayerData.equipment_data["Item"] == null:
			data["target_item_id"] = null
			data["target_texture"] = null
			data["target_stack"] = null
			return true
		# Swap item
		else:
			data["target_item_id"] = PlayerData.equipment_data["Item"]
			data["target_texture"] = texture
			data["target_stack"] = PlayerData.equipment_data["Stack"]
			return true
	else:
		return false

func drop_data(_pos, data):
	var origin_slot = data["origin_node"].get_parent().get_name()
	if data["origin_node"] == self:
		pass
	else:
		# Update the data of the origin
		if data["origin_panel"] == "Inventory":
			PlayerData.inv_data[origin_slot]["Item"] = data["target_item_id"]
			PlayerData.inv_data[origin_slot]["Stack"] = data["target_stack"]
		
		# Update the texture and label of the origin
		if data["origin_panel"] == "Inventory" and data["target_item_id"] == null:
			data["origin_node"].texture = null
			data["origin_node"].get_node("../TextureRect/Stack").set_text("")
		else:
			data["origin_node"].texture = data["target_texture"]
			if data["target_stack"] != null and data["target_stack"] > 1:
				data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["target_stack"]))
			
		# Update the texture, label and data of the target
		PlayerData.equipment_data["Item"] = data["origin_item_id"]
		texture = data["origin_texture"]
		PlayerData.equipment_data["Stack"] = data["origin_stack"]
		get_parent().get_parent().get_parent().get_parent().find_node("Damage").set_text(tr("ATTACK") + ": " + str(GameData.item_data[str(PlayerData.equipment_data["Item"])]["Attack"]))
		Utils.get_current_player().set_attack(GameData.item_data[str(PlayerData.equipment_data["Item"])]["Attack"])

# ToolTips
func _on_Icon_mouse_entered():
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "CharacterInterface"
	tool_tip_instance.slot = get_parent().get_name()
	
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(100,-50)
	
	add_child(tool_tip_instance)
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()


func _on_Icon_mouse_exited():
	get_node("ToolTip").free()

