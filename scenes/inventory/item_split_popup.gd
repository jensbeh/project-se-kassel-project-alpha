extends Popup

var data

func _ready():
	get_node("NinePatchRect/MarginContainer/HBoxContainer/Amount").grab_focus()


func _on_Confirm_pressed():
	var split_amount = get_node("NinePatchRect/MarginContainer/HBoxContainer/Amount").get_text()
	if split_amount == "":
		split_amount = 1
	if int(split_amount) >= data["origin_stack"] and data["origin_stack"] != 0:
		split_amount = data["origin_stack"] -1
	# max 999 stack size
	if int(split_amount) > Constants.MAX_STACK_SIZE:
		split_amount = Constants.MAX_STACK_SIZE
	if data["origin_stack"] == 0 and !data["origin_stackable"]:
		split_amount = 1
	get_parent().SplitStack(int(split_amount), data)
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_Confirm_pressed()
	if event.is_action_pressed("esc"):
		queue_free()
