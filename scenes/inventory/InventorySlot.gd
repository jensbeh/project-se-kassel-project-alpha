extends TextureRect

var tool_tip = load(Constants.TOOLTIP)
var split_popup = load(Constants.SPLIT_POPUP)

# Get information about drag item
func get_drag_data(_pos):
	var slot = get_parent().get_name()
	if PlayerData.inv_data[slot]["Item"] != null:
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = "Inventory"
		data["origin_item_id"] = PlayerData.inv_data[slot]["Item"]
		data["origin_slot"] = GameData.item_data[str(PlayerData.inv_data[slot]["Item"])]
		data["origin_texture"] = texture
		data["origin_stackable"] = GameData.item_data[str(PlayerData.inv_data[slot]["Item"])]["Stackable"]
		data["origin_stack"] = PlayerData.inv_data[slot]["Stack"]
		
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
	var target_slot = get_parent().get_name()
	# Move item
	if PlayerData.inv_data[target_slot]["Item"] == null:
		data["target_item_id"] = null
		data["target_texture"] = null
		data["target_stack"] = null
		return true
	# Swap item
	else:
		if Input.is_action_pressed("secondary") or data["origin_stack"] == 0:
			return false
		else:
			if data["origin_panel"] != "CharacterInterface" or GameData.item_data[str(data["target_item_id"])]["Category"] == "Weapon":
				data["target_item_id"] = PlayerData.inv_data[target_slot]["Item"]
				data["target_texture"] = texture
				data["target_stack"] = PlayerData.inv_data[target_slot]["Stack"]
				if data["target_stack"] == Constants.MAX_STACK_SIZE or data["target_stack"] == 0:
					return false
				else:
					return true
			else:
				return false


func drop_data(_pos, data):
	var target_slot = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	if data["origin_node"] == self:
		pass
	else:
		if Input.is_action_pressed("secondary") and data["origin_stack"] > 1 or data["origin_stack"] == 0:
			var split_popup_instance = split_popup.instance()
			split_popup_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(0,100)
			split_popup_instance.data = data
			add_child(split_popup_instance)
			get_node("ItemSplitPopup").show()
		else:
			# Update the data of the origin
			if (data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"] and 
			data["origin_panel"] == "Inventory"):
				if data["target_stack"] + data["origin_stack"] <= Constants.MAX_STACK_SIZE:
					PlayerData.inv_data[origin_slot]["Item"] = null
					PlayerData.inv_data[origin_slot]["Stack"] = null
				else:
					PlayerData.inv_data[origin_slot]["Stack"] = (PlayerData.inv_data[origin_slot]["Stack"] - 
					(Constants.MAX_STACK_SIZE - data["target_stack"]))
			elif (data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"] and 
			data["origin_panel"] == "TradeInventory"):
				if data["target_stack"] + data["origin_stack"] <= Constants.MAX_STACK_SIZE:
					MerchantData.inv_data[origin_slot]["Item"] = null
					MerchantData.inv_data[origin_slot]["Stack"] = null
				else:
					MerchantData.inv_data[origin_slot]["Stack"] = (MerchantData.inv_data[origin_slot]["Stack"] - 
					(Constants.MAX_STACK_SIZE - data["target_stack"]))
			elif data["origin_panel"] == "Inventory":
				PlayerData.inv_data[origin_slot]["Item"] = data["target_item_id"]
				PlayerData.inv_data[origin_slot]["Stack"] = data["target_stack"]
			elif data["origin_panel"] == "TradeInventory":
				MerchantData.inv_data[origin_slot]["Item"] = data["target_item_id"]
				MerchantData.inv_data[origin_slot]["Stack"] = data["target_stack"]
			else:
				PlayerData.equipment_data["Item"] = data["target_item_id"]
				PlayerData.equipment_data["Stack"] = data["target_stack"]
			# Update the texture and label of the origin
			if data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"]:
				if data["target_stack"] + data["origin_stack"] <= Constants.MAX_STACK_SIZE:
					data["origin_node"].texture = null
					data["origin_node"].get_node("../TextureRect/Stack").set_text("")
				else:
					data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["origin_stack"] - 
					(Constants.MAX_STACK_SIZE - data["target_stack"])))
			elif data["origin_panel"] == "TradeInventory" and data["target_item_id"] == null:
				data["origin_node"].texture = null
				data["origin_node"].get_node("../TextureRect/Stack").set_text("")
			else:
				data["origin_node"].texture = data["target_texture"]
				if data["target_stack"] != null and data["target_stack"] > 1:
					data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["target_stack"]))
				elif data["origin_panel"] == "Inventory" or data["origin_panel"] == "TradeInventory":
					data["origin_node"].get_node("../TextureRect/Stack").set_text("")
				
			# Update the texture, label and data of the target
			if data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"]:
				var new_stack = data["target_stack"] + data["origin_stack"]
				if new_stack > Constants.MAX_STACK_SIZE:
						new_stack = Constants.MAX_STACK_SIZE
				PlayerData.inv_data[target_slot]["Stack"] = new_stack
				get_node("../TextureRect/Stack").set_text(str(new_stack))
			else:
				PlayerData.inv_data[target_slot]["Item"] = data["origin_item_id"]
				texture = data["origin_texture"]
				PlayerData.inv_data[target_slot]["Stack"] = data["origin_stack"]
				if data["origin_stack"] != null and data["origin_stack"] > 1:
					get_node("../TextureRect/Stack").set_text(str(data["origin_stack"]))
				else:
					get_node("../TextureRect/Stack").set_text("")
					
		show_hide_stack_label(data)

func SplitStack(split_amount, data):
	var target_slot = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	
	if MerchantData.inv_data[origin_slot]["Stack"] != 0 and data["origin_panel"] == "TradeInventory":
		MerchantData.inv_data[origin_slot]["Stack"] = data["origin_stack"] - split_amount
	else:
		PlayerData.inv_data[origin_slot]["Stack"] = data["origin_stack"] - split_amount
	PlayerData.inv_data[target_slot]["Item"] = data["origin_item_id"]
	PlayerData.inv_data[target_slot]["Stack"] = split_amount
	texture = data["origin_texture"]
	# origin
	if data["origin_stack"] - split_amount > 1:
		data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["origin_stack"] - split_amount))
	else:
		data["origin_node"].get_node("../TextureRect/Stack").set_text("")
	# target
	if split_amount > 1:
		get_node("../TextureRect/Stack").set_text(str(split_amount))
	else:
		get_node("../TextureRect/Stack").set_text("")
		
	show_hide_stack_label(data)

func show_hide_stack_label(data):
	if data["origin_panel"] != "CharacterInterface":
		if (int(data["origin_node"].get_parent().get_node("TextureRect/Stack").get_text()) > 1 and 
		data["origin_node"].get_parent().get_node("TextureRect/Stack").get_text() != null):
			data["origin_node"].get_parent().get_node("TextureRect").visible = true
		else:
			data["origin_node"].get_parent().get_node("TextureRect").visible = false
		if (int(get_parent().get_node("TextureRect/Stack").get_text()) > 1 and 
		get_parent().get_node("TextureRect/Stack").get_text() != null):
			get_parent().get_node("TextureRect").visible = true
		else:
			get_parent().get_node("TextureRect").visible = false

# ToolTips
func _on_Icon_mouse_entered():
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "Inventory"
	tool_tip_instance.slot = get_parent().get_name()
	
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(64,64)
	
	add_child(tool_tip_instance)
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()


func _on_Icon_mouse_exited():
	get_node("ToolTip").free()
