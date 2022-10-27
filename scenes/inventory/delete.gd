extends TextureRect

onready var dialog = get_node("AcceptDialog")
var item_slot
var node
var panel


# Style of the Popup
func _ready():
	var styleup1 = StyleBoxFlat.new()
	styleup1.set_bg_color(Color(1, 0, 0))
	styleup1.set_corner_radius_all(5)
	var hover = StyleBoxFlat.new()
	hover.set_bg_color(Color(0.956863, 0.25098, 0.25098))
	hover.set_corner_radius_all(5)
	hover.set_expand_margin_all(3)
	var pressed = StyleBoxFlat.new()
	pressed.set_bg_color(Color(0.722656, 0.03952, 0.03952))
	pressed.set_corner_radius_all(5)
	pressed.set_expand_margin_all(3)
	var styleup2 = StyleBoxFlat.new()
	styleup2.set_corner_radius_all(5)
	styleup2.set_bg_color(Color(0.6, 0.6, 0.6))
	var hover2 = StyleBoxFlat.new()
	hover2.set_bg_color(Color(0.7, 0.7, 0.7))
	hover2.set_corner_radius_all(5)
	hover2.set_expand_margin_all(3)
	var pressed2 = StyleBoxFlat.new()
	pressed2.set_bg_color(Color(0.5, 0.5, 0.5))
	pressed2.set_corner_radius_all(5)
	pressed2.set_expand_margin_all(3)
	dialog.get_ok().set_text(tr("DISCARD"))
	dialog.get_cancel().set_text(tr("CANCLE"))
	dialog.get_cancel().add_stylebox_override("normal", styleup2)
	dialog.get_cancel().add_stylebox_override("hover", hover2)
	dialog.get_cancel().add_stylebox_override("pressed", pressed2)
	dialog.get_ok().add_stylebox_override("normal", styleup1)
	dialog.get_ok().add_stylebox_override("hover", hover)
	dialog.get_ok().add_stylebox_override("pressed", pressed)


# Method that Items can dropped here
func can_drop_data(_pos, _data):
	return true


# Set Item Name and show Popup
func drop_data(_pos, data):
	dialog.get_label().set_align(1)
	dialog.get_label().set_valign(1)
	node = data["origin_node"]
	panel = data["origin_panel"]
	item_slot = node.get_parent().get_name()
	if PlayerData.inv_data[item_slot]["Stack"] > 1:
		dialog.set_text(" " + tr("DELETEITEM") + " " + "\n" + " \"" + 
		tr(str(GameData.item_data[str(PlayerData.inv_data[item_slot]["Item"])]["Name"])) 
		+ " x " + str(PlayerData.inv_data[item_slot]["Stack"]) + "\" ? ")
	else:
		dialog.set_text(" " + tr("DELETEITEM") + " " + "\n" + " \"" + 
		tr(str(GameData.item_data[str(PlayerData.inv_data[item_slot]["Item"])]["Name"])) 
		+ "\" ? ")
	
	dialog.popup()
	
	Utils.get_current_player().set_dragging(false)


# Delete Item
func _on_AcceptDialog_confirmed():
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
