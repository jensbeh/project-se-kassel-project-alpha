extends TextureRect

var item_slot
var node
var panel

var item
var stack


# Method that Items can dropped here
func can_drop_data(_pos, _data):
	return true


 #Delete Item
func delete_item():
	if panel == "Inventory":
		PlayerData.inv_data[item_slot]["Item"] = null
		PlayerData.inv_data[item_slot]["Stack"] = null
		node.get_child(0).texture = null
		node.get_node("../TextureRect/Stack").set_text("")
		node.get_parent().get_node("TextureRect").visible = false
		# Cooldown
		node.timer.stop()
		node._on_Timer_timeout()
	elif panel == "CharacterInterface":
		PlayerData.equipment_data[item_slot]["Item"] = null
		PlayerData.equipment_data[item_slot]["Stack"] = null
		PlayerData.inv_data[item_slot]["Item"] = null
		PlayerData.inv_data[item_slot]["Stack"] = null
		node.get_child(0).texture = null
		# Stack Label and Cooldown
		if node.get_parent().get_name() == "Hotbar":
			node.get_node("TextureRect/Stack").set_text("")
			node.get_node("TextureRect").visible = false
			node.timer.stop()
			node._on_Timer_timeout()
			Utils.get_hotbar().load_hotbar()
		elif node.get_parent().get_name() == "Light":
			Utils.get_character_interface().find_node("LightRadius").set_text(tr("LIGHT") + ": " + "0")
			Utils.get_current_player().set_light(0)
		elif node.get_parent().get_name() == "Weapon":
			Utils.get_character_interface().find_node("Damage").set_text(tr("ATTACK") + ": " + "0")
			Utils.get_character_interface().find_node("Attack-Speed").set_text(tr("ATTACK-SPEED") + ": " + "0")
			Utils.get_character_interface().find_node("Knockback").set_text(tr("KNOCKBACK") + ": " + "0")
			Utils.get_current_player().set_weapon(null, 0, 0, 0)


func get_drag_data(_pos):
	if item != null:
		Utils.get_sound_player().stream = Constants.PreloadedSounds.Select
		Utils.get_sound_player().play(0.03)
		var data = {}
		data["origin_node"] = self
		data["origin_panel"] = "Delete"
		data["origin_item_id"] = item
		data["origin_slot"] = "Delete"
		data["origin_texture"] = get_child(0).texture
		data["origin_frame"] = get_child(0).frame
		data["origin_stackable"] = GameData.item_data[str(item)]["Stackable"]
		data["origin_stack"] = stack
		
		# Texture wich will drag
		var drag_texture = Sprite.new()
		if GameData.item_data[str(item)]["Texture"] == "item_icons_1":
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


func drop_data(_pos, data):
	# Sound
	Utils.get_sound_player().stream = Constants.PreloadedSounds.Delete
	Utils.get_sound_player().play(0.03)
	
	node = data["origin_node"]
	panel = data["origin_panel"]
	item = data["origin_item_id"]
	stack = data["origin_stack"]
	item_slot = node.get_parent().get_name()
	if data["origin_stack"] != null and data["origin_stack"] > 1:
		get_node("TextureRect/Stack").set_text(str(data["origin_stack"]))
		get_node("TextureRect").show()
	else:
		get_node("TextureRect/Stack").set_text("")
		get_node("TextureRect").hide()
	get_child(0).texture = data["origin_texture"]
	get_child(0).frame = data["origin_frame"]
	delete_item()
	verify_target_texture(data)


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

