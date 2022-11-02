extends CanvasLayer

var dialogPath = null
var textSpeed = 0.05
var dialog
var trade = false
var phraseNum = 0
var finished = false
var obj_name
var origin
var type
var death = false


func start(origin_obj, looted_value, treasure_type):
	Utils.get_ui().is_dialog = true
	obj_name = origin_obj.name
	origin = origin_obj
	type = treasure_type
	if typeof(looted_value) != TYPE_BOOL and looted_value == "Death":
		dialog = treasure_type
		death = true
	elif typeof(looted_value) == TYPE_BOOL:
		if "treasure" in obj_name and !looted_value:
			obj_name = "treasure"
			if treasure_type == "1":
				get_node("Trade/Icon").frame = 185
			elif treasure_type == "2":
				get_node("Trade/Icon").frame = 186
			else:
				get_node("Trade/Icon").frame = 271
				get_node("Trade/Label").show()
				get_node("Trade/Label").set_text(tr("OPEN"))
				obj_name = "open"
		elif "treasure" in obj_name and looted_value:
			obj_name = "empty"
		else:
			get_node("Trade/Icon").frame = 203
	else:
		obj_name = "open"
		get_node("Trade/Icon").frame = 271
		get_node("Trade/Label").show()
		get_node("Trade/Label").set_text(tr("OPEN"))
	Utils.get_control_notes().hide()
	$Timer.wait_time = textSpeed
	# Get language
	if !death:
		var lang = TranslationServer.get_locale()
		dialogPath = "res://assets/dialogue/"+ obj_name + "_" + lang + ".json"
		dialog = getDialog()
	nextPhrase()


func _process(_delta):
	$Skip.visible = finished
	if Input.is_action_just_pressed("e") and $Text.visible_characters > 2:
		if finished:
			nextPhrase()
		else:
			$Text.visible_characters = len($Text.text)


# Open dialog text
func getDialog():
	var f = File.new()
	if f.file_exists(dialogPath):
		f.open(dialogPath, File.READ)
		var json = f.get_as_text()
		var output = parse_json(json)
		if typeof(output) == TYPE_ARRAY:
			return output
	return []


func nextPhrase():
	# At the end of the dialog
	if phraseNum >= len(dialog):
		trade = false
		close_dialog()
	# Show text
	else:
		finished = false
		$Name.bbcode_text = dialog[phraseNum].name + ":"
		$Text.bbcode_text = dialog[phraseNum].text
		$Text.visible_characters = 0
		while $Text.visible_characters < len($Text.text):
			$Text.visible_characters += 1
			$Timer.start()
			yield($Timer, "timeout")
		finished = true
		phraseNum += 1
	
	if phraseNum >= len(dialog):
		if obj_name in ["bella", "sam", "lea", "heinz"]:
			$Trade.visible = true
			trade = true
		elif "treasure" in obj_name or "open" in obj_name:
			$Trade.visible = true
			trade = true


func _on_Button_pressed():
	if finished:
		nextPhrase()
		trade = false
	else:
		$Text.visible_characters = len($Text.text)


func close_dialog():
	$Trade.visible = false
	phraseNum = 0
	finished = false
	if !trade:
		Utils.get_current_player().set_player_can_interact(true)
		Utils.get_current_player().set_movement(true)
		Utils.get_current_player().set_movment_animation(true)
		Utils.get_current_player().pause_player(false)
		Utils.get_ui().is_dialog = false
		# reset npc interaction state
		if !death:
			if !"treasure" in obj_name and !"empty" in obj_name and !"open" in obj_name:
				for npc in origin.get_parent().get_children():
					npc.set_interacted(false)
			else:
				if type != "3":
					Utils.get_scene_manager().get_current_scene().reset_interaction()
				else:
					origin.reset_interaction()
	Utils.get_control_notes().show()
	get_parent().remove_child(self)
	queue_free()


func _on_Trade_pressed():
	if !"treasure" in obj_name and !"empty" in obj_name and !"open" in obj_name:
		Utils.get_control_notes().show()
		MerchantData.set_path(obj_name)
		MerchantData._ready()
		PlayerData._ready()
		close_dialog()
		# Show trade inventory
		Utils.get_ui().add_child(load(Constants.TRADE_INVENTORY_PATH).instance())
		Utils.get_trade_inventory().set_name(obj_name)
	else:
		Utils.get_control_notes().show()
		if type != "3":
			if Utils.get_scene_manager().get_current_scene().player_has_key(origin):
				Utils.get_scene_manager().get_current_scene().open_loot_panel(origin)
			else:
				trade = false
		else:
			origin.open_loot_panel()
		close_dialog()
