extends TextureRect

var tool_tip = load(Constants.TOOLTIP)
var split_popup = load(Constants.SPLIT_POPUP)
var inv_slot = load(Constants.TRADE_INV_SLOT)

# Get information about drag item
func get_drag_data(_pos):
	Utils.get_current_player().set_dragging(true)
	var slot = get_parent().get_name()
	if MerchantData.inv_data[slot]["Item"] != null:
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = "TradeInventory"
		data["origin_item_id"] = MerchantData.inv_data[slot]["Item"]
		data["origin_slot"] = GameData.item_data[str(MerchantData.inv_data[slot]["Item"])]
		data["origin_texture"] = get_child(0).texture
		data["origin_frame"] = get_child(0).frame
		data["origin_stackable"] = GameData.item_data[str(MerchantData.inv_data[slot]["Item"])]["Stackable"]
		data["origin_stack"] = MerchantData.inv_data[slot]["Stack"]
	
		var drag_texture = Sprite.new()
		if GameData.item_data[str(MerchantData.inv_data[slot]["Item"])]["Texture"] == "item_icons_1":
			drag_texture.set_scale(Vector2(1.5,1.5))
			drag_texture.set_hframes(16)
			drag_texture.set_vframes(27)
			drag_texture.texture = get_child(0).texture
			drag_texture.frame = get_child(0).frame
		else:
			drag_texture.set_scale(Vector2(2.5,2.5))
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
	var player_gold = int(Utils.get_current_player().get_gold())
	# Move item
	if MerchantData.inv_data[target_slot]["Item"] == null:
		data["target_item_id"] = null
		data["target_texture"] = null
		data["target_stack"] = null
		data["target_frame"] = null
		return true
	# Swap item
	else:
		data["target_item_id"] = MerchantData.inv_data[target_slot]["Item"]
		data["target_texture"] = get_child(0).texture
		data["target_frame"] = get_child(0).frame
		data["target_stack"] = MerchantData.inv_data[target_slot]["Stack"]
		# sell on stack
		if data["target_item_id"] == data["origin_item_id"] and (data["origin_stackable"] or data["target_stack"] == 0): 
			return true
		elif data["target_stack"] == 0:
			return false
		elif (data["target_item_id"] != null and data["target_item_id"] != data["origin_item_id"]) and (Input.is_action_pressed("secondary") or data["target_stack"] == 0):
			return false
		else:
			# swap and check if you have enough gold
			if data["origin_panel"] == "Inventory":
				if int(GameData.item_data[str(data["target_item_id"])]["Worth"]) * int(
					data["target_stack"]) <= player_gold + int(GameData.item_data[str(
						data["origin_item_id"])]["Worth"]) * int(data["origin_stack"]):
					return true
				else:
					return false
			else:
				return true


func drop_data(_pos, data):
	var target_slot = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	var player_gold = int(Utils.get_current_player().get_gold())
	if data["origin_node"] == self:
		pass
	else:
		# splitting
		if Input.is_action_pressed("secondary") and data["origin_stack"] > 1 and data["origin_stack"] != 0:
			var split_popup_instance = split_popup.instance()
			split_popup_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(0,100)
			split_popup_instance.data = data
			add_child(split_popup_instance)
			get_node("ItemSplitPopup").show()
		elif data["origin_stack"] != 0:
			# paying
			if data["origin_panel"] == "Inventory":
				if data["target_stack"] == Constants.MAX_STACK_SIZE:
					pass
				# swap
				elif data["target_item_id"] != null and (!data["origin_stackable"] or data["target_item_id"] != data["origin_item_id"]):
					Utils.get_current_player().set_gold(player_gold + ((int(GameData.item_data[str(
						data["origin_item_id"])]["Worth"])) * int(data["origin_stack"])) - 
						(int(GameData.item_data[str(data["target_item_id"])]["Worth"])) * int(data["target_stack"]))
				# sell
				else:
					Utils.get_current_player().set_gold(player_gold + (int(GameData.item_data[str(data["origin_item_id"])]["Worth"])) * int(data["origin_stack"]))
				Utils.get_scene_manager().get_child(3).get_node("TradeInventory").find_node("Inventory").get_child(0).find_node("Gold").set_text(
					"Gold: " + str(Utils.get_current_player().get_gold()))
			# Update the data of the origin
			# stacking 
			if (data["target_item_id"] == data["origin_item_id"] and (data["origin_stackable"] or data["target_stack"] == 0) and 
			data["origin_panel"] == "TradeInventory"):
				if data["target_stack"] + data["origin_stack"] <= Constants.MAX_STACK_SIZE:
					MerchantData.inv_data[origin_slot]["Item"] = null
					MerchantData.inv_data[origin_slot]["Stack"] = null
					MerchantData.inv_data[origin_slot]["Time"] = null
				else:
					MerchantData.inv_data[origin_slot]["Stack"] = (MerchantData.inv_data[origin_slot]["Stack"] - 
					(Constants.MAX_STACK_SIZE - data["target_stack"]))
					MerchantData.inv_data[origin_slot]["Time"] = OS.get_system_time_msecs()
			elif (data["target_item_id"] == data["origin_item_id"] and (data["origin_stackable"] or data["target_stack"] == 0) and 
			data["origin_panel"] == "Inventory"):
				if data["target_stack"] + data["origin_stack"] <= Constants.MAX_STACK_SIZE:
					PlayerData.inv_data[origin_slot]["Item"] = null
					PlayerData.inv_data[origin_slot]["Stack"] = null
				else:
					PlayerData.inv_data[origin_slot]["Stack"] = (PlayerData.inv_data[origin_slot]["Stack"] - 
					(Constants.MAX_STACK_SIZE - data["target_stack"]))
			# swap with item or empty
			elif data["origin_panel"] == "TradeInventory":
				MerchantData.inv_data[origin_slot]["Item"] = data["target_item_id"]
				MerchantData.inv_data[origin_slot]["Stack"] = data["target_stack"]
				if data["target_item_id"] != null:
					MerchantData.inv_data[origin_slot]["Time"] = OS.get_system_time_msecs()
				else:
					MerchantData.inv_data[origin_slot]["Time"] = null
			else:
				PlayerData.inv_data[origin_slot]["Item"] = data["target_item_id"]
				PlayerData.inv_data[origin_slot]["Stack"] = data["target_stack"]
				
			# Update the texture of the origin
			# stacking
			if data["target_item_id"] == data["origin_item_id"] and (data["origin_stackable"] or data["target_stack"] == 0):
				if data["target_stack"] + data["origin_stack"] <= Constants.MAX_STACK_SIZE:
					data["origin_node"].get_child(0).texture = null
					data["origin_node"].get_node("../TextureRect/Stack").set_text("")
				else:
					data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["origin_stack"] - 
					(Constants.MAX_STACK_SIZE - data["target_stack"])))
			# swap
			elif data["origin_panel"] == "Inventory" and data["target_item_id"] == null:
				data["origin_node"].get_child(0).texture = null
				data["origin_node"].get_node("../TextureRect/Stack").set_text("")
			else:
				data["origin_node"].get_child(0).texture = data["target_texture"]
				if data["target_frame"] != null:
					data["origin_node"].get_child(0).frame = data["target_frame"]
				verify_origin_texture(data)
				if data["target_stack"] != null and data["target_stack"] > 1:
					data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["target_stack"]))
				else:
					data["origin_node"].get_node("../TextureRect/Stack").set_text("")
				
			# Update the texture, label and data of the target
			# stacking
			if data["target_item_id"] == data["origin_item_id"] and (data["origin_stackable"] or data["target_stack"] == 0):
				if data["target_stack"] != 0:
					var new_stack = data["target_stack"] + data["origin_stack"]
					if new_stack > Constants.MAX_STACK_SIZE:
						new_stack = Constants.MAX_STACK_SIZE
					MerchantData.inv_data[target_slot]["Stack"] = new_stack
					MerchantData.inv_data[target_slot]["Time"] = OS.get_system_time_msecs()
					get_node("../TextureRect/Stack").set_text(str(new_stack))
			else:
				# swaping
				MerchantData.inv_data[target_slot]["Item"] = data["origin_item_id"]
				verify_target_texture(data)
				get_child(0).texture = data["origin_texture"]
				get_child(0).frame = data["origin_frame"]
				MerchantData.inv_data[target_slot]["Stack"] = data["origin_stack"]
				if MerchantData.inv_data[target_slot]["Item"] != null:
					MerchantData.inv_data[target_slot]["Time"] = OS.get_system_time_msecs()
				else:
					MerchantData.inv_data[target_slot]["Time"] = null
				if data["origin_stack"] != null and data["origin_stack"] > 1:
					get_node("../TextureRect/Stack").set_text(str(data["origin_stack"]))
				else:
					get_node("../TextureRect/Stack").set_text("")
				hide_tooltip()
				show_tooltip()

			show_hide_stack_label(data)
		check_slots()
	Utils.get_current_player().set_dragging(false)

func SplitStack(split_amount, data):
	var target_slot = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	var player_gold = int(Utils.get_current_player().get_gold())
	var new_stack_size
	# paying in case of buying and selling
	if data["origin_panel"] == "Inventory":
		Utils.get_current_player().set_gold(player_gold + (int(GameData.item_data[str(data["origin_item_id"])]["Worth"]) * split_amount))
		Utils.get_scene_manager().get_node("UI").get_node("TradeInventory").find_node("Inventory").get_child(0).find_node("Gold").set_text(
			"Gold: " + str(Utils.get_current_player().get_gold()))
	
	if MerchantData.inv_data[origin_slot]["Stack"] != 0 and data["origin_panel"] == "TradeInventory":
		MerchantData.inv_data[origin_slot]["Stack"] = data["origin_stack"] - split_amount
	elif PlayerData.inv_data[origin_slot]["Stack"] != 0 and data["origin_panel"] == "Inventory":
		PlayerData.inv_data[origin_slot]["Stack"] = data["origin_stack"] - split_amount
	MerchantData.inv_data[target_slot]["Item"] = data["origin_item_id"]
	MerchantData.inv_data[target_slot]["Time"] = OS.get_system_time_msecs()
	if data["target_stack"] != null:
		new_stack_size = data["target_stack"] + split_amount
	else:
		new_stack_size = split_amount
	MerchantData.inv_data[target_slot]["Stack"] = new_stack_size
	verify_target_texture(data)
	get_child(0).texture = data["origin_texture"]
	get_child(0).frame = data["origin_frame"]
	# origin
	if data["origin_stack"] - split_amount > 1:
		data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["origin_stack"] - split_amount))
	else:
		data["origin_node"].get_node("../TextureRect/Stack").set_text("")
	# target
	if new_stack_size > 1:
		get_node("../TextureRect/Stack").set_text(str(new_stack_size))
	else:
		get_node("../TextureRect/Stack").set_text("")
	
	show_hide_stack_label(data)
	check_slots()

func show_hide_stack_label(data):
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

func verify_origin_texture(data):
	if data["target_item_id"] != null:
		if GameData.item_data[str(data["target_item_id"])]["Texture"] == "item_icons_1":
			get_child(0).set_scale(Vector2(1.5,1.5))
			get_child(0).set_hframes(16)
			get_child(0).set_vframes(27)
		else:
			get_child(0).set_scale(Vector2(2.5,2.5))
			get_child(0).set_hframes(13)
			get_child(0).set_vframes(15)
	
	
func verify_target_texture(data):
	if data["origin_item_id"] != null:
		if GameData.item_data[str(data["origin_item_id"])]["Texture"] == "item_icons_1":
			get_child(0).set_scale(Vector2(1.5,1.5))
			get_child(0).set_hframes(16)
			get_child(0).set_vframes(27)
		else:
			get_child(0).set_scale(Vector2(2.5,2.5))
			get_child(0).set_hframes(13)
			get_child(0).set_vframes(15)

# ToolTips
func _on_Icon_mouse_entered():
	show_tooltip()

func _on_Icon_mouse_exited():
	hide_tooltip()
	
func show_tooltip():
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "TradeInventory"
	tool_tip_instance.slot = get_parent().get_name()
	
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(64,64)
	
	add_child(tool_tip_instance)
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()

func hide_tooltip():
	get_node("ToolTip").free()


func check_slots():
	var free = false
	var free2 = false
	var trade = get_parent().get_parent()
	var slots = MerchantData.inv_data.size()
	for i in MerchantData.inv_data:
		if MerchantData.inv_data[i]["Item"] == null:
			free = true
	if !free:
		for i in range(slots+1,slots +7):
			var inv_slot_new = inv_slot.instance()
			MerchantData.inv_data["Inv" + str(i)] = {"Item":null,"Stack":null, "Time":null}
			trade.add_child(inv_slot_new,true)
		MerchantData.save_merchant_inventory()
	elif slots > 30:
		for i in range(0,6):
			if MerchantData.inv_data["Inv" + str(MerchantData.inv_data.size() - i)]["Item"] != null:
				free2 = true
		if !free2:
			slots = MerchantData.inv_data.size()
			for i in range(0,6):
				MerchantData.inv_data.erase("Inv" + str(slots - i))
				trade.remove_child(trade.get_node("Inv" + str(slots - i)))
			
