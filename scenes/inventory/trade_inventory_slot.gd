extends TextureRect

# get information about drag item
func get_drag_data(_pos):
	var slot = get_parent().get_name()
	# check if slot != null
	var data = {}
	data["origin_node"] = self
	data["origin_panel"] = "TradeInventory"
	data["origin_item_id"] = MerchantData.inv_data[slot]["Item"]
	data["origin_slot"] = slot
	data["origin_texture"] = texture
	
	# texture wich will drag
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = texture
	drag_texture.rect_size = Vector2(100,100)
	
	# pos on mouse while drag
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.rect_position = -0.5 * drag_texture.rect_size
	set_drag_preview(control)
	
	return data

# check if we can drop an item to this slot
func can_drop_data(_pos, data):
	var target_slot = get_parent().get_name()
	# move item
	if MerchantData.inv_data[target_slot]["Item"] == null:
		data["target_item_id"] = null
		data["target_texture"] = null
		return true
	# swap item
	else:
		data["target_item_id"] = MerchantData.inv_data[target_slot]["Item"]
		data["target_texture"] = texture
		return true


func drop_data(_pos, data):
	var target_slot = get_parent().get_name()
	
	# update the data of the origin
	if data["origin_panel"] == "Inventory":
		PlayerData.inv_data[target_slot]["Item"] = data["target_item_id"]
	else:
		MerchantData.inv_data[target_slot]["Item"] = data["target_item_id"]
	
	# update the texture of the origin
	if data["origin_panel"] == "TradeInventory" and data["target_item_id"] == null:
		var default_texture = load("res://assets/Icon_Items/Empty Slot.png")
		data["origin_node"].texture = default_texture
	else:
		data["origin_node"].texture = data["target_texture"]
		
	# update the texture and data of the target
	PlayerData.inv_data[target_slot]["Item"] = data["origin_item_id"]
	texture = data["origin_texture"]