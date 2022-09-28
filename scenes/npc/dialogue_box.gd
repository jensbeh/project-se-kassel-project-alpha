extends CanvasLayer

var dialogPath = null
var textSpeed = 0.05
var dialog
var trade = false
var phraseNum = 0
var finished = false
var origin
var key


func _ready():
	$TextureRect.visible = false
	$HSeparator.visible = false
	$Button.visible = false
	$Name.visible = false
	$Text.visible = false


func start(origin_obj, key_value):
	key = key_value
	origin = origin_obj
	Utils.get_control_notes().hide()
	$TextureRect.visible = true
	$HSeparator.visible = true
	$Button.visible = true
	$Name.visible = true
	$Text.visible = true
	$Timer.wait_time = textSpeed
	# Get language
	var lang = TranslationServer.get_locale()
	dialogPath = "res://assets/dialogue/"+ origin.name + "_" + lang + ".json"
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
		if origin.name in ["bella", "sam", "lea", "heinz"]:
			$Trade.visible = true
			trade = true
		elif "treasure" in origin.name and key:
			$Trade.visible = true
			trade = true


func _on_Button_pressed():
	if finished:
		nextPhrase()
		trade = false
	else:
		$Text.visible_characters = len($Text.text)


func close_dialog():
	$TextureRect.visible = false
	$HSeparator.visible = false
	$Button.visible = false
	$Name.visible = false
	$Text.visible = false
	$Trade.visible = false
	phraseNum = 0
	finished = false
	if !trade:
		Utils.get_current_player().set_player_can_interact(true)
		Utils.get_current_player().set_movement(true)
		Utils.get_current_player().set_movment_animation(true)
		# reset npc interaction state
		if !"treasure" in origin.name:#empty#######################################
			for npc in origin.get_parent().get_children():
				npc.set_interacted(false)
	Utils.get_control_notes().show()
	get_parent().remove_child(self)
	queue_free()

# add dialog box by treasures ################################################
#todo remove dialog box by npcs #####################################################
func _on_Trade_pressed():#todo loot_panel and key remove###############################
	Utils.get_control_notes().show()
	MerchantData.set_path(origin.name)
	MerchantData._ready()
	PlayerData._ready()
	close_dialog()
	# Show trade inventory
	Utils.get_ui().add_child(load(Constants.TRADE_INVENTORY_PATH).instance())
	Utils.get_trade_inventory().set_name(origin.name)
