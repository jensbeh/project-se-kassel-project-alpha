extends Control

onready var exp_bar = get_node("NinePatchRect/ProgressBar")
onready var clock = get_node("Clock/clock")
onready var exp_value = get_node("NinePatchRect/ProgressBar/EXPValue")
onready var life_bar = get_node("Lifebar")
var hearts = 3


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


# LifeBar
func set_life(new_value):
	# Factor = 100 / 80 -> 20 = empty = 27-37, 62-72
	# 3 beacuse 3 hearts -> 1/3 each
	if hearts == 3:
		if new_value < 34:
			life_bar.value = new_value / 1.25
		elif new_value < 66:
			# Minimum value from this heart + value - maxvalue of heart before / factor
			life_bar.value = 37 + (new_value - 34) / 1.25
		else:
			# Minimum value from this heart + value - maxvalue of heart before / factor		
			life_bar.value = 72 + (new_value - 66) / 1.25
	if hearts == 4:
		if new_value < 26:
			life_bar.value = new_value / 1.25
		elif new_value < 51:
			life_bar.value = 27 + (new_value - 26) / 1.25
		elif new_value < 76:
			life_bar.value = 53 + (new_value - 51) / 1.25
		else:
			life_bar.value = 79 + (new_value - 76) / 1.25
	if hearts == 5:
		if new_value < 22:
			life_bar.value = new_value / 1.3
		elif new_value < 41:
			life_bar.value = 23 + (new_value - 22) / 1.3
		elif new_value < 62:
			life_bar.value = 43 + (new_value - 41) / 1.3
		elif new_value < 81:
			life_bar.value = 64 + (new_value - 62) / 1.3
		else:
			life_bar.value = 84 + (new_value - 81) / 1.3

	if life_bar.value <= 0:
		print("Spieler ist tot")


func change_heart_number(number_heart):
	hearts = number_heart
	life_bar.texture_progress = load("res://assets/ui/lifebar_background_" + number_heart + ".png")
	life_bar.texture_under = load("res://assets/ui/lifebar_" + number_heart + ".png")
	
	
