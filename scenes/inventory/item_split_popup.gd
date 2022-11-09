extends Popup

var data
onready var line_editRegEx = RegEx.new()
var old_text = ""
onready var split_amount_node = get_node("NinePatchRect/MarginContainer/HBoxContainer/Amount")

func _ready():
	Utils.get_sound_player().stream = Constants.PreloadedSounds.Click
	Utils.get_sound_player().play(0.03)
	line_editRegEx.compile("^[0-9.]*$")
	split_amount_node.grab_focus()
	
func _on_Amount_text_changed(new_text):
	if line_editRegEx.search(new_text):
		old_text = str(new_text)
	else:
		if old_text == "":
			old_text = "1"
		split_amount_node.text = old_text
		split_amount_node.set_cursor_position(split_amount_node.text.length())

func _on_Confirm_pressed():
	Utils.get_sound_player().stream = Constants.PreloadedSounds.Click
	Utils.get_sound_player().play(0.03)
	var split_amount = split_amount_node.get_text()
	if split_amount == "":
		split_amount = 1
	if int(split_amount) >= data["origin_stack"] and data["origin_stack"] != 0:
		split_amount = data["origin_stack"] -1
	# max 999 stack size
	if int(split_amount) > Constants.MAX_STACK_SIZE:
		split_amount = Constants.MAX_STACK_SIZE
	if data["target_stack"] != null:
		if data["target_stack"] + data["origin_stack"] > Constants.MAX_STACK_SIZE:
			split_amount = Constants.MAX_STACK_SIZE - data["target_stack"]
	if data["origin_stack"] == 0 and !data["origin_stackable"]:
		split_amount = 1
	var player_gold = int(Utils.get_current_player().get_gold())
	if player_gold != 0 and data["origin_panel"] == "TradeInventory":
		if int(GameData.item_data[str(data["origin_item_id"])]["Worth"]) * int(split_amount) > player_gold:
			split_amount = int(player_gold/(int(GameData.item_data[str(data["origin_item_id"])]["Worth"])))
	if int(split_amount) != 0:
		get_parent().SplitStack(int(split_amount), data)
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_Confirm_pressed()
	if event.is_action_pressed("esc"):
		queue_free()
	# close popup if clicked outside
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0),rect_size).has_point(evLocal.position):
			queue_free()
