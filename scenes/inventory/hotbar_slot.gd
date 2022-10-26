extends TextureRect

var tool_tip = load(Constants.TOOLTIP)
var split_popup = load(Constants.SPLIT_POPUP)

onready var time_label = get_node("TextureProgress/Time")
onready var cooldown_texture = get_node("TextureProgress")
var disabled = false
onready var timer = get_node("../Timer")
var swap = false
var stack = false
var type


func _ready():
	time_label.hide()
	timer.wait_time = Constants.HEALTH_COOLDOWN
	cooldown_texture.value = 0
	set_process(false)
	timer.set_one_shot(true)


# Update Cooldwon Label
func _process(_delta):
	time_label.text = "%2.1f" % timer.time_left
	if type == "Stamina":
		cooldown_texture.value = int((timer.time_left / Constants.STAMINA_POTION_COOLDOWN) * 100)
	else:
		cooldown_texture.value = int((timer.time_left / Constants.HEALTH_COOLDOWN) * 100)


func _on_Timer_timeout():
	cooldown_texture.value = 0
	disabled = false
	time_label.hide()
	set_process(false)


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
		data["origin_stackable"] = true
		data["origin_stack"] = PlayerData.inv_data[slot]["Stack"]
		
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
	if GameData.item_data[str(data["origin_item_id"])]["Category"] in ["Potion", "Food"]:
		if PlayerData.equipment_data[target_slot]["Item"] == null:
			data["target_item_id"] = null
			data["target_texture"] = null
			data["target_stack"] = null
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
		if Input.is_action_pressed("secondary") and data["origin_stack"] > 1 or data["origin_stack"] == 0:
			if data["origin_stackable"]:
				var split_popup_instance = split_popup.instance()
				split_popup_instance.rect_position = get_parent().get_global_transform_with_canvas().origin + Vector2(0,100)
				split_popup_instance.data = data
				add_child(split_popup_instance)
				get_node("ItemSplitPopup").show()
			else:
				SplitStack(1,data)
		else:
			# Update the data of the origin
			# stacking 
			if data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"]:
				if data["target_stack"] + data["origin_stack"] <= Constants.MAX_STACK_SIZE:
					PlayerData.inv_data[origin_slot]["Item"] = null
					PlayerData.inv_data[origin_slot]["Stack"] = null
				else:
					PlayerData.inv_data[origin_slot]["Stack"] = (PlayerData.inv_data[origin_slot]["Stack"] - 
					(Constants.MAX_STACK_SIZE - data["target_stack"]))
			# swap
			elif data["origin_panel"] == "Inventory":
				PlayerData.inv_data[origin_slot]["Item"] = data["target_item_id"]
				PlayerData.inv_data[origin_slot]["Stack"] = data["target_stack"]
			
			# Update the texture and label of the origin
			# stacking
			if data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"]:
				if data["target_stack"] + data["origin_stack"] <= Constants.MAX_STACK_SIZE:
					data["origin_node"].get_child(0).texture = null
					data["origin_node"].get_node("../TextureRect/Stack").set_text("")
					stack = true
				else:
					data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["origin_stack"] - 
					(Constants.MAX_STACK_SIZE - data["target_stack"])))
			# swap
			elif data["origin_panel"] == "Inventory" and data["target_item_id"] == null:
				data["origin_node"].get_child(0).texture = null
				data["origin_node"].get_node("../TextureRect/Stack").set_text("")
			else:
				data["origin_node"].get_child(0).texture = data["target_texture"]
				data["origin_node"].get_child(0).frame = data["target_frame"]
				verify_origin_texture(data)
				if data["target_stack"] != null and data["target_stack"] > 1:
					data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["target_stack"]))
				else:
					data["origin_node"].get_node("../TextureRect/Stack").set_text("")
					
			# Update the texture, label and data of the target
			if data["target_item_id"] == data["origin_item_id"] and data["origin_stackable"]:
				var new_stack = 0
				new_stack = data["target_stack"] + data["origin_stack"]
				if new_stack > Constants.MAX_STACK_SIZE:
						new_stack = Constants.MAX_STACK_SIZE
				PlayerData.inv_data[target_slot]["Stack"] = new_stack
				get_node("TextureRect/Stack").set_text(str(new_stack))
			else:
				PlayerData.equipment_data[target_slot]["Item"] = data["origin_item_id"]
				verify_target_texture(data)
				get_child(0).texture = data["origin_texture"]
				get_child(0).frame = data["origin_frame"]
				PlayerData.equipment_data[target_slot]["Stack"] = data["origin_stack"]
				if data["origin_stack"] != null and data["origin_stack"] > 1:
					get_node("TextureRect/Stack").set_text(str(data["origin_stack"]))
				else:
					get_node("TextureRect/Stack").set_text("")
				swap = true
			hide_tooltip()
			show_tooltip()
			show_hide_stack_label(data)
			check_cooldown(data)
	
	Utils.get_hotbar().load_hotbar()
	
	Utils.get_current_player().set_dragging(false)



func SplitStack(split_amount, data):
	var target_slot = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	var new_stack_size
	
	PlayerData.inv_data[origin_slot]["Stack"] = data["origin_stack"] - split_amount
	PlayerData.equipment_data[target_slot]["Item"] = data["origin_item_id"]
	if data["target_stack"] != null:
		new_stack_size = data["target_stack"] + split_amount
	else:
		new_stack_size = split_amount
	PlayerData.equipment_data[target_slot]["Stack"] = new_stack_size
	verify_target_texture(data)
	get_child(0).texture = data["origin_texture"]
	get_child(0).frame = data["origin_frame"]
	# origin label
	if data["origin_stack"] - split_amount > 1:
		data["origin_node"].get_node("../TextureRect/Stack").set_text(str(data["origin_stack"] - split_amount))
	else:
		data["origin_node"].get_node("../TextureRect/Stack").set_text("")
	# target label
	if new_stack_size > 1:
		get_node("TextureRect/Stack").set_text(str(new_stack_size))
	else:
		get_node("TextureRect/Stack").set_text("")
	
	check_cooldown(data)
	
	Utils.get_hotbar().load_hotbar()
	show_hide_stack_label(data)


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


func show_hide_stack_label(data):
	if (int(data["origin_node"].get_parent().get_node("TextureRect/Stack").get_text()) > 1 and 
	data["origin_node"].get_parent().get_node("TextureRect/Stack").get_text() != null):
		data["origin_node"].get_parent().get_node("TextureRect").visible = true
	else:
		data["origin_node"].get_parent().get_node("TextureRect").visible = false
	if (int(get_node("TextureRect/Stack").get_text()) > 1 and 
	get_node("TextureRect/Stack").get_text() != null):
		get_node("TextureRect").visible = true
	else:
		get_node("TextureRect").visible = false


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
	

# Use Item
func _on_Icon_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		var slot = get_parent().get_name()
		if PlayerData.equipment_data[slot]["Item"] != null and !disabled:
			if GameData.item_data[str(PlayerData.equipment_data[slot]["Item"])]["Category"] in ["Potion", "Food"]:
				if PlayerData.equipment_data[slot]["Stack"] != null:
					PlayerData.equipment_data[slot]["Stack"] -= 1
					var cooldown
					if GameData.item_data[str(PlayerData.equipment_data[slot]["Item"])].has("Stamina"):
						Utils.get_current_player().set_stamina(Utils.get_current_player().player_stamina + 
						GameData.item_data[str(PlayerData.equipment_data[slot]["Item"])]["Stamina"])
						type = "Stamina"
						cooldown = Constants.STAMINA_POTION_COOLDOWN
						Utils.get_current_player().stamina_cooldown = cooldown
					else:
						Utils.get_current_player().set_current_health(int(Utils.get_current_player().get_current_health()) + 
						int(GameData.item_data[str(PlayerData.equipment_data[slot]["Item"])]["Health"]))
						type = "Health"
						cooldown = Constants.HEALTH_COOLDOWN
						Utils.get_current_player().health_cooldown = cooldown
					if PlayerData.equipment_data["Hotbar"]["Stack"] > 0:
						set_cooldown(cooldown, type)
					if PlayerData.equipment_data[slot]["Stack"] <= 0:
						PlayerData.equipment_data[slot]["Stack"] = null
						PlayerData.equipment_data[slot]["Item"] = null
						get_node("TextureRect/Stack").set_text("")
						get_node("TextureRect").visible = false
						get_node("Sprite").set_texture(null)
					elif PlayerData.equipment_data["Hotbar"]["Stack"] == 1:
						get_node("TextureRect/Stack").set_text("")
						get_node("TextureRect").visible = false
					else:
						get_node("TextureRect/Stack").set_text(str(PlayerData.equipment_data[slot]["Stack"]))
					PlayerData.inv_data["Hotbar"] = PlayerData.equipment_data["Hotbar"]
					# sync cooldown
					if type == "Stamina":
						Utils.get_hotbar().set_cooldown_stamina(cooldown, type)
					elif type == "Health":
						Utils.get_hotbar().set_cooldown_health(cooldown, type)
					Utils.get_hotbar().update_label()
					Utils.get_character_interface().find_node("Inventory").set_cooldown(cooldown, type)
					hide_tooltip()
					show_tooltip()


# starts cooldown
func set_cooldown(cooldown, new_type):
	type = new_type
	if PlayerData.equipment_data["Hotbar"]["Item"] != null:
		timer.wait_time = cooldown
		timer.start()
		disabled = true
		set_process(true)
		time_label.show()
		if  PlayerData.equipment_data["Hotbar"]["Item"] == null:
			time_label.hide()
			cooldown_texture.hide()
		else:
			cooldown_texture.show()


# cooldown by moving an item
func check_cooldown(data):
	var cooldown
	var cooldown_origin
	if stack:
		cooldown = 0
		cooldown_origin = timer.time_left
		stack = false
	elif swap:
		cooldown = timer.time_left
		cooldown_origin = data["origin_node"].get_node("../Timer").time_left
		swap = false
	else:
		cooldown = data["origin_node"].get_node("../Timer").time_left
		cooldown_origin = data["origin_node"].get_node("../Timer").time_left
	if cooldown_origin != 0:
		timer.wait_time = cooldown_origin
		timer.start()
		disabled = true
		set_process(true)
		time_label.show()
		cooldown_texture.show()
	else:
		timer.stop()
		disabled = false
		set_process(false)
		time_label.hide()
		cooldown_texture.value = 0
	if cooldown != 0:
		data["origin_node"].get_node("../Timer").wait_time = cooldown
		data["origin_node"].get_node("../Timer").start()
		data["origin_node"].disabled = true
		data["origin_node"].get_node("TextureProgress/Time").show()
		data["origin_node"].set_process(true)
	else:
		data["origin_node"].get_node("../Timer").stop()
		data["origin_node"].disabled = false
		data["origin_node"].get_node("TextureProgress").value = 0
		data["origin_node"].get_node("TextureProgress/Time").hide()
		data["origin_node"].set_process(false)
	if data["origin_slot"].has("Stamina"):
		type = "Stamina"
	elif data["origin_slot"].has("Health") and data["origin_slot"]["Health"] != null:
		type = "Health"
	if data["target_item_id"] != null:
		if GameData.item_data[str(data["target_item_id"])].has("Stamina"):
			data["origin_node"].type = "Stamina"
		elif GameData.item_data[str(data["target_item_id"])]["Health"] != null:
			data["origin_node"].type = "Health"
	
