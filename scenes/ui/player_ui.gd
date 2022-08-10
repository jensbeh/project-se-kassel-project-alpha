extends Control

onready var exp_bar = get_node("NinePatchRect/ProgressBar")
onready var clock = get_node("Clock/clock")
onready var exp_value = get_node("NinePatchRect/ProgressBar/EXPValue")


func _ready():
	pass # Replace with function body.


# Set expbar value
func set_exp(new_value):
	exp_value.set_text("EXP: " + str(new_value))
	exp_bar.value = int(new_value)
	# Max exp for level
	if exp_bar.value >= exp_bar.max_value:
		Utils.get_current_player().set_level(int(Utils.get_current_player().get_level()) +1)
		Utils.get_current_player().set_exp(new_value - exp_bar.max_value)


# Clock
func set_time(new_hour, new_minute):
	clock.set_text(str("%02d" % new_hour) + ":" + str("%02d" % new_minute))
